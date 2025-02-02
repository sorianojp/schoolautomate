<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//if(false)
if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UC") || strSchCode.startsWith("UB") || strSchCode.startsWith("SWU")) {%>
	<jsp:forward page="./class_list_cit.jsp" />

<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg(strStudId)
{
	//fill up the major name and course name,
	document.classlist.subject_name.value = document.classlist.subject[document.classlist.subject.selectedIndex].text;
	document.classlist.section_name.value = document.classlist.section[document.classlist.section.selectedIndex].text;
	//document.classlist.subject_name.value = document.classlist.subject[document.classlist.subject.selectedIndex].text;
document.classlist.view_all.value ="";
document.classlist.target="_blank";
document.classlist.action ="./class_lists_print.jsp";
document.classlist.submit();
}
function ReloadPage()
{
	if(document.classlist.course_index.selectedIndex == 0) {
		alert("Please select a course.");
		return;
	}
	document.classlist.view_all.value ="";
	document.classlist.target="_self";
	document.classlist.action ="./class_lists.jsp";
	document.classlist.submit();
}
function ShowCList()
{
	document.classlist.showCList.value="1";
	ReloadPage();
}
function ChangeCourse()
{
	document.classlist.showCList.value="0";
	ReloadPage();
}
function ChangeMajor()
{
	document.classlist.showCList.value="0";
	ReloadPage();
}
function ViewAll() {
	if(document.classlist.view_all_sec.value.length == 0) 
		alert("No section list found.");
	else {
		document.classlist.subject_name.value = document.classlist.subject[document.classlist.subject.selectedIndex].text;
		document.classlist.section_name.value = document.classlist.section[document.classlist.section.selectedIndex].text;
		document.classlist.view_all.value = "1";
		document.classlist.target="_blank";
		document.classlist.action ="./class_lists_showall.jsp";
		document.classlist.submit();
	}	
}
function ChangeSubject() {
	document.classlist.sub_code_.value = document.classlist.subject[document.classlist.subject.selectedIndex].text;
	ReloadPage();
}
function GoToSPCFormat() {
	location = "./VMA_reports/class_list_per_section_simple_spc.jsp";
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	String strDegreeType = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-class list","class_lists.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS-CLASS LIST",request.getRemoteAddr(),
														null);
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

//end of authenticaion code.
	boolean bolIsRestricted = false;
	if(strSchCode.startsWith("DLSHSI")) {
		strTemp = "select auth_list_index from USER_AUTH_LIST where user_index = "+(String)request.getSession(false).getAttribute("userIndex")+
					" and is_valid = 1 and sub_mod_index = (select sub_mod_index from sub_module where sub_mod_name = 'Grade Releasing - Restricted')";
		if(dbOP.getResultOfAQuery(strTemp, 0) != null)	
			bolIsRestricted = true;

	}	

Vector vSecList = null;
Vector vSubList = null;
Vector vSecDetail = null;
Vector vClassList = null;

ReportEnrollment reportEnrl= new ReportEnrollment();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("course_index").length() > 0)
{
	vSubList = reportEnrl.getSubList(dbOP, request.getParameter("course_index"),request.getParameter("major_index"),
			request.getParameter("year_level"),request.getParameter("offering_sem"),request.getParameter("sy_from"),request.getParameter("sy_to"));
	if(vSubList != null)
		strDegType = (String)vSubList.elementAt(0);
	else
		strErrMsg = reportEnrl.getErrMsg();
}
if(WI.fillTextValue("subject").length() > 0 && WI.fillTextValue("showCList").compareTo("0") != 0)
{
	vSecList = reportEnrl.getSubSecList(dbOP,request.getParameter("sy_from"),request.getParameter("sy_to"),
								request.getParameter("offering_sem"),request.getParameter("subject"), strDegType);
	if(vSecList == null)
		strErrMsg = reportEnrl.getErrMsg();
}
if(WI.fillTextValue("section").length() > 0 && WI.fillTextValue("showCList").compareTo("0") != 0)
{
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,request.getParameter("section"));

	if(vSecDetail == null && WI.fillTextValue("is_firsttime").length() > 0)
		strErrMsg = reportEnrl.getErrMsg();
}

if(vSecDetail != null && vSecDetail.size() > 0 && WI.fillTextValue("showCList").compareTo("0") != 0)
{
	vClassList = reportEnrl.getClassList(dbOP,request);
	if(vClassList == null)
		strErrMsg = reportEnrl.getErrMsg();
}
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("0") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");
if(strErrMsg == null) strErrMsg = "";
%>
<form action="" method="post" name="classlist">

  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          REPORTS - CLASS LISTS PAGE ::::
        
          </strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">
<%
strTemp = WI.fillTextValue("show_not_validated");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="show_not_validated" value="1" <%=strTemp%>>
        <strong><font color="#0000FF">Display Students in the class but not validated.</font></strong></td>
      <td align="right">
<%if(strSchCode.startsWith("SPC")){%>
	  <a href="javascript:GoToSPCFormat();">Go To Other Format</a>
<%}%>
<%if(strSchCode.startsWith("NEU")){%>
	  <a href="./class_list_cit.jsp">Print in excel format</a> &nbsp;&nbsp;&nbsp;
	  <a href="./class_record_neu.jsp">Print Class Record</a>
<%}%>
	  </td>
    </tr>
	<tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">Course:
        <input type="text" name="scroll_course" size="10" style="font-size:12px;" 
		onKeyUp="AutoScrollList('classlist.scroll_course','classlist.course_index',true);" autocomplete="off">
        <font size="1">(enter course to scroll the list)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2">Course&nbsp; <select name="course_index" onChange="ChangeCourse()" style="width:500px;"> 
          <option value="0">Select Any</option>
<%
if(bolIsRestricted)
	strTemp = " and c_index = "+WI.getStrValue((String)request.getSession(false).getAttribute("info_faculty_basic.c_index"), "0");
else
	strTemp = "";
%>
          <%=dbOP.loadCombo("course_index","course_code, course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+strTemp+" order by course_code asc",
		  		request.getParameter("course_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2">Major&nbsp;&nbsp;&nbsp; <select name="major_index" onChange="ChangeMajor()">
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
      <td width="1%">&nbsp;</td>
      <td height="25" colspan="2"> <%
if(strDegreeType == null || (strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0) ){%>
        Year Level : 
        <select name="year_level">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select> <%}%> <%if(strDegreeType != null && strDegreeType.compareTo("3") ==0){%>
        Prep or Proper: 
        <select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select> <%}%> </td>
    </tr>
    <tr> 
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="50%" height="25">SY/Term &nbsp; <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("classlist","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="offering_sem">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="49%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>

<%
if(vSubList != null && vSubList.size() > 0){%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr  >
      <td height="25" colspan="4"><div align="center">
          <hr size="1">
        </div></td>
    </tr>
    <tr >
      <td>&nbsp;</td>
      <td height="25" colspan="3">Subject Code: <font size="1">
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollList('classlist.scroll_sub','classlist.subject',true);">
(enter subject code to scroll the list)</font></td>
    </tr>
    <tr >
      <td>&nbsp;</td>
      <td height="25" colspan="3"><select name="subject" onChange="ChangeSubject()" style="width:500px;">
		<option value="0">Select a subject</option>
<%
strTemp = WI.fillTextValue("subject");
for(int i=1; i<vSubList.size();++i){
	if(strTemp.compareTo((String)vSubList.elementAt(i)) ==0){%>
		<option value="<%=(String)vSubList.elementAt(i)%>" selected><%=(String)vSubList.elementAt(i+1)%></option>
<%}else{%><option value="<%=(String)vSubList.elementAt(i)%>"><%=(String)vSubList.elementAt(i+1)%></option>
<%}
++i;
}%>
        </select> 

<%//I have to show NSTP drop down, if subject is NSTP
if(WI.fillTextValue("sub_code_").toUpperCase().indexOf("NSTP") != -1) {%>
 - <select name="nstp_val" style="font-size:11px;">
	<option value="">ALL</option>
	<%=dbOP.loadCombo("distinct NSTP_VAL","NSTP_VAL"," from NSTP_VALUES order by NSTP_VALUES.NSTP_VAL asc", 
		WI.fillTextValue("nstp_val"), false)%>
</select>
<%}%>	  </td>
    </tr>
    <tr >
      <td width="1%">&nbsp;</td>
      <td height="25" colspan="3">Description : <strong>
	  <%if(WI.fillTextValue("subject").length() > 0 && WI.fillTextValue("showCList").compareTo("0") != 0){
strTemp = dbOP.mapOneToOther("SUBJECT", "sub_index", request.getParameter("subject"), "sub_name",null );
if(strTemp == null) strTemp = "";  %>
	  <%=strTemp%>
	  <%}%>
<input type="hidden" name="subject_desc" value="<%=strTemp%>">
	  </strong></td>
    </tr>
    <tr >
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vSecList != null && vSecList.size() > 0){%>
	
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="0%">&nbsp;</td>
      <td height="25">Section 
        <select name="section" onChange="ReloadPage()" style="font-size:11px">
          <option value="">Select a section</option>
          <%
strTemp = WI.fillTextValue("section");
for(int i=0; i<vSecList.size();i +=2){
	if(strTemp.compareTo((String)vSecList.elementAt(i)) ==0){%>
          <option value="<%=(String)vSecList.elementAt(i)%>" selected><%=(String)vSecList.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vSecList.elementAt(i)%>"><%=(String)vSecList.elementAt(i+1)%></option>
          <%}
}%>
        </select>
        &nbsp;&nbsp;<font size="1">View student in all section.<a href="javascript:ViewAll();"><img src="../../../images/view.gif" border="0"></a></font> 
        <select name="no_of_stud" style="font-size:9px">
		<option value="20">20</option>
		<option value="25">25</option>
		<option value="26">26</option>
		<option value="27">27</option>
		<option value="28">28</option>
		<option value="29">29</option>
		<option value="30">30</option>
		<option value="31">31</option>
		<option value="32">32</option>
		<option value="33">33</option>
		<option value="34">34</option>
		<option value="35">35</option>
		<option value="36">36</option>
		<option value="37">37</option>
		<option value="38">38</option>
		<option value="39">39</option>
		<option value="40">40</option>
		</select>	  </td>
      <td width="39%" height="25">Instructor :
	  <%if(vSecDetail != null){%>
	  <%=WI.getStrValue(vSecDetail.elementAt(0))%>
	  <%}%></td>
    </tr>
</table>
<%if(vSecDetail != null){%>
 <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%> 
	<tr>
	<td>&nbsp;</td>
	<td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
	<td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
	  <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
	<td>&nbsp;</td>
	</tr>  
	<%}%>  
	<tr>
	<td>&nbsp;</td>
	  <td align="center">&nbsp;</td>
	  <td align="center">&nbsp;</td>
	  <td align="center">&nbsp;</td>
	<td>&nbsp;</td>
	</tr>   
</table>		
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="1%">&nbsp;</td>
      <td width="12%" height="24"><div align="left">Sort List By : </div></td>
      <td height="24" colspan="2"> <select name="or_by">
          <option value="asc">Ascending</option>
          <%
strTemp =WI.fillTextValue("or_by");
if(strTemp.compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="or1">
          <option value="0">None</option>
          <%
strTemp =WI.fillTextValue("or1");
if(strTemp.compareTo("lname") ==0){%>
          <option value="lname" selected>Lastname</option>
          <%}else{%>
          <option value="lname">Lastname</option>
          <%}if(strTemp.compareTo("fname") ==0){%>
          <option value="fname" selected>Firstname</option>
          <%}else{%>
          <option value="fname">Firstname</option>
          <%}if(strTemp.compareTo("course_offered.course_code") ==0){%>
          <option value="course_offered.course_code" selected>Course</option>
          <%}else{%>
          <option value="course_offered.course_code">Course</option>
          <%}if(strTemp.compareTo("gender") ==0){%>
          <option value="gender" selected>Gender</option>
          <%}else{%>
          <option value="gender">Gender</option>
          <%}%>
        </select> <select name="or2">
          <option value="0">None</option>
          <%
strTemp =WI.fillTextValue("or2");
if(strTemp.compareTo("lname") ==0){%>
          <option value="lname" selected>Lastname</option>
          <%}else{%>
          <option value="lname">Lastname</option>
          <%}if(strTemp.compareTo("fname") ==0){%>
          <option value="fname" selected>Firstname</option>
          <%}else{%>
          <option value="fname">Firstname</option>
          <%}if(strTemp.compareTo("course_offered.course_code") ==0){%>
          <option value="course_offered.course_code" selected>Course</option>
          <%}else{%>
          <option value="course_offered.course_code">Course</option>
          <%}if(strTemp.compareTo("gender") ==0){%>
          <option value="gender" selected>Gender</option>
          <%}else{%>
          <option value="gender">Gender</option>
          <%}%>
        </select> <select name="or3">
          <option value="0">None</option>
          <%
strTemp =WI.fillTextValue("or3");
if(strTemp.compareTo("lname") ==0){%>
          <option value="lname" selected>Lastname</option>
          <%}else{%>
          <option value="lname">Lastname</option>
          <%}if(strTemp.compareTo("fname") ==0){%>
          <option value="fname" selected>Firstname</option>
          <%}else{%>
          <option value="fname">Firstname</option>
          <%}if(strTemp.compareTo("course_offered.course_code") ==0){%>
          <option value="course_offered.course_code" selected>Course</option>
          <%}else{%>
          <option value="course_offered.course_code">Course</option>
          <%}if(strTemp.compareTo("gender") ==0){%>
          <option value="gender" selected>Gender</option>
          <%}else{%>
          <option value="gender">Gender</option>
          <%}%>
        </select> <select name="or4">
          <option value="0">None</option>
          <%
strTemp =WI.fillTextValue("or4");
if(strTemp.compareTo("lname") ==0){%>
          <option value="lname" selected>Lastname</option>
          <%}else{%>
          <option value="lname">Lastname</option>
          <%}if(strTemp.compareTo("fname") ==0){%>
          <option value="fname" selected>Firstname</option>
          <%}else{%>
          <option value="fname">Firstname</option>
          <%}if(strTemp.compareTo("course_offered.course_code") ==0){%>
          <option value="course_offered.course_code" selected>Course</option>
          <%}else{%>
          <option value="course_offered.course_code">Course</option>
          <%}if(strTemp.compareTo("gender") ==0){%>
          <option value="gender" selected>Gender</option>
          <%}else{%>
          <option value="gender">Gender</option>
          <%}%>
        </select> </td>
    </tr>
    <tr > 
      <td>&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td width="53%">&nbsp;</td>
      <td width="34%" height="24">&nbsp;</td>
    </tr>
    <tr > 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td><div align="right">
          <a href="javascript:ShowCList();"><img  src="../../../images/form_proceed.gif" border="0"></a>
        </div></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr >
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("grade_relation");
if(strTemp.equals("0") || request.getParameter("grade_relation") == null)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
	  <input name="grade_relation" type="radio" value="0"<%=strErrMsg%>>Show all student &nbsp;&nbsp;
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>      <input name="grade_relation" type="radio" value="1"<%=strErrMsg%>>
Show student without Final grade &nbsp;&nbsp;
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>      <input name="grade_relation" type="radio" value="2"<%=strErrMsg%>>
Show student with Final grade </td>
    </tr>
  </table>
<%
if(vClassList != null && vClassList.size()> 0){
//int iTotalStud = Integer.parseInt( (String)vClassList.elementAt(0));
/*int iStudCount = 0;
int iTotalPageCount = iTotalStud/30;
if(iTotalStud %30 > 0)
	++iTotalPageCount;
int iPageCount = 1;*/
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td>&nbsp;</td>
      <td height="25" width="60%">TOTAL STUDENTS ENROLLED IN THIS CLASS : <strong><%=(String)vClassList.elementAt(0)%></strong></td>
      <td width="39%" style="font-size:9px;"><div align="right">
	  Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 26;
if(WI.fillTextValue("rows_per_pg").length() > 0) 
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i =25; i < 60; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	  <option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	  &nbsp;&nbsp;&nbsp;
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print list</font></div></td>
    </tr>
  <tr>
      <td height="25" bgcolor="#B9B292" colspan="3"><div align="center">LIST OF STUDENTS OFFICIALLY
          ENROLLED </div></td>
  </tr>
</table>

<%
if(WI.fillTextValue("show_not_validated").length() == 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="14%" height="27" rowspan="2" align="center"><font size="1"><strong>STUDENT
        ID</strong></font></td>
      <td height="20" colspan="3" align="center"><strong><font size="1">STUDENT
        NAME</font></strong></td>
      <td width="20%" rowspan="2" align="center"><font size="1"><strong>COURSE 
        CODE</strong></font></td>
      <td width="14%" rowspan="2" align="center"><font size="1"><strong>MAJOR</strong></font></td>
      <td width="7%" rowspan="2" align="center"><font size="1"><strong>YEAR LEVEL</strong></font></td>
      <td width="7%" rowspan="2" align="center"><font size="1"><strong>GENDER</strong></font></td>
    </tr>
    <tr>
      <td width="17%" align="center"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="16%" align="center"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>MI</strong></font></td>
    </tr>
<%
int iIndexOf = 0;
for(int i=1; i<vClassList.size(); ++i){
strTemp = WI.getStrValue(vClassList.elementAt(i+3)," ");

if(strTemp.length() > 1 ) {
	iIndexOf = strTemp.indexOf(" ",1);
	if(iIndexOf > -1 && strTemp.length() > (iIndexOf + 1) )
		strTemp = String.valueOf(strTemp.charAt(0))+"."+strTemp.charAt(iIndexOf + 1);
	else	
		strTemp = String.valueOf(strTemp.charAt(0));
}
%>
    <tr>
      <td height="25"><div align="center"><%=(String)vClassList.elementAt(i)%></div></td>
      <td><%=(String)vClassList.elementAt(i+1)%></td>
      <td><%=(String)vClassList.elementAt(i+2)%></td>
      <td><div align="center"><%=strTemp%>&nbsp;</div></td>
      <td><%=(String)vClassList.elementAt(i+4)%></td>
      <td><%=WI.getStrValue(vClassList.elementAt(i+5),"&nbsp;")%></td>
      <td><div align="center"><%=WI.getStrValue(vClassList.elementAt(i+6),"N/A")%></div></td>
      <td><div align="center"><%=(String)vClassList.elementAt(i+7)%></div></td>
    </tr>
<%
i = i+7;
}%>
  </table>
<%}else{//show the students not confirmed.%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="14%" rowspan="2" align="center"><strong><font size="1">DATE OF 
        ENROLLMENT</font></strong></td>
      <td width="14%" height="27" rowspan="2" align="center"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="27" colspan="3" align="center"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="20%" rowspan="2" align="center"><font size="1"><strong>COURSE 
        CODE</strong></font></td>
      <td width="14%" rowspan="2" align="center"><font size="1"><strong>MAJOR</strong></font></td>
      <td width="7%" rowspan="2" align="center"><font size="1"><strong>YR</strong></font></td>
      <td width="7%" rowspan="2" align="center"><font size="1"><strong>GEN</strong></font></td>
    </tr>
    <tr> 
      <td width="17%" align="center"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="16%" align="center"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>MI</strong></font></td>
    </tr>
    <%
for(int i=1; i<vClassList.size(); i += 9){%>
    <tr> 
      <td align="center"><%=(String)vClassList.elementAt(i + 8)%></td>
      <td height="25"><div align="center"><%=(String)vClassList.elementAt(i)%></div></td>
      <td><%=(String)vClassList.elementAt(i+1)%></td>
      <td><%=(String)vClassList.elementAt(i+2)%></td>
      <td><div align="center"><%=WI.getStrValue(vClassList.elementAt(i+3)," ").charAt(0)%>&nbsp;</div></td>
      <td><%=(String)vClassList.elementAt(i+4)%></td>
      <td><%=WI.getStrValue(vClassList.elementAt(i+5),"&nbsp;")%></td>
      <td><div align="center"><%=WI.getStrValue(vClassList.elementAt(i+6),"N/A")%></div></td>
      <td><div align="center"><%=(String)vClassList.elementAt(i+7)%></div></td>
    </tr>
    <%}%>
  </table>
<%}%>  

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print list</font></div></td>
    </tr>
 </table>
<%		}//if vClassList is not null;
	}//if subject list is not null
}//only if sub section list is not null
%>
   <table width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="is_firsttime" value="0">
<input type="hidden" name="subject_name">
<input type="hidden" name="section_name">
<input type="hidden" name="showCList" value="">
<%strTemp = "";
if(vSecList != null && vSecList.size() > 0) {
	for(int i=0; i<vSecList.size();i +=2){
		if(strTemp.length() == 0)
			strTemp = (String)vSecList.elementAt(i);
		else	
			strTemp += ","+(String)vSecList.elementAt(i);
	}
}
%>
<input type="hidden" name="sub_code_" value="<%=WI.fillTextValue("sub_code_")%>">
<input type="hidden" name="view_all_sec" value="<%=strTemp%>">
<input type="hidden" name="view_all">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
