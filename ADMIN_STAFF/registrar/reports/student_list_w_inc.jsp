<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector" %>
<%

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	 if(strSchCode.startsWith("AUF")){
	  response.sendRedirect("./student_list_w_inc_auf.jsp");
	  return; 
	 }

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	if(WI.fillTextValue("print_pg").length() > 0) {%>
		<jsp:forward page="./student_list_w_inc_print.jsp" />
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ViewDetail(strStudID)
{	
	var pgLoc = "./student_list_w_inc_view_one.jsp?stud_id="+escape(strStudID)+
		"&report_type=<%=WI.fillTextValue("report_type")%>&report_type_name="+escape("<%=WI.fillTextValue("report_type_name")%>");
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus()	
}
function UpdateReportName() {
	document.getElementById("report_n").innerHTML = document.report_registrar.report_name.value;
}
function PrintPage() {
	document.report_registrar.print_pg.value ='1';
	document.report_registrar.submit();
	return;
	
	//not used.. 
	
	var addCon = "";
	if(document.report_registrar.rem_course.checked)
		addCon = "&rem_course=1";
	if(document.report_registrar.rem_fac.checked)
		addCon += "&rem_fac=1";
	if(document.report_registrar.year_level.selectedIndex > 0) 
		addCon += "&year_level="+document.report_registrar.year_level.selectedIndex;
	if(document.report_registrar.section_.value.length > 0) 
		addCon += "&section_="+document.report_registrar.section_.value;

	if(document.report_registrar.rem_tc && document.report_registrar.rem_tc.checked) 
		addCon += "&rem_tc=1";
	if(document.report_registrar.show_no_of_stud && document.report_registrar.show_no_of_stud.checked) 
		addCon += "&show_no_of_stud=1";
	//alert(addCon);
	
	
	var pgLoc = "./student_list_w_inc_print.jsp?report_type=<%=WI.fillTextValue("report_type")%>&course_index="+
	document.report_registrar.course_index[document.report_registrar.course_index.selectedIndex].value+
	"&major_index="+document.report_registrar.major_index.value+"&lname_from="+
	document.report_registrar.lname_from[document.report_registrar.lname_from.selectedIndex].text+
	"&lname_to="+document.report_registrar.lname_to[document.report_registrar.lname_to.selectedIndex].text+
	"&report_type_name="+
		escape(document.report_registrar.report_type[document.report_registrar.report_type.selectedIndex].text)+
		"&min_no="+document.report_registrar.min_no.value+"&sy_from="+document.report_registrar.sy_from.value+
		"&sy_to="+document.report_registrar.sy_to.value+
		"&semester="+document.report_registrar.semester[document.report_registrar.semester.selectedIndex].value+
		addCon+"&s1="+document.report_registrar.s1[document.report_registrar.s1.selectedIndex].value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.report_registrar.print_pg.value ='';
	document.report_registrar.report_type_name.value = 
			document.report_registrar.report_type[document.report_registrar.report_type.selectedIndex].text;
	this.SubmitOnce('report_registrar');
}
function ShowResult() {
	document.report_registrar.showResult.value = "1";
	ReloadPage();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ChangeRemarkName() {
	if(document.report_registrar.report_type.selectedIndex == 0)
		document.report_regisrar.remark_name.value = "";
	else	
		document.report_regisrar.remark_name.value = 
			document.report_regisrar.report_type[document.report_regisrar.report_type.selectedIndex].text;
	///document.report_registrar.gradeName.value = "Test";
}
///ajax here to load major..
function loadMajor() {
		var objCOA=document.getElementById("load_major");
 		var objCourseInput = document.report_registrar.course_index[document.report_registrar.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?all=1&methodRef=104&course_ref="+objCourseInput+"&sel_name=major_index";
		//alert(strURL);
		this.processRequest(strURL);
}
</script>

<body bgcolor="#D2AE72">
<%
	String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Student list with INC","student_list_w_inc.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","REPORTS",request.getRemoteAddr(),
							//							"student_list_w_inc.jsp");
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
ReportRegistrarExtn RR = new ReportRegistrarExtn();
Vector vRetResult      = null;
String[] strConvertAlphabet =
		{"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
if(WI.fillTextValue("showResult").length() > 0){
	vRetResult = RR.listStudWithINC(dbOP, request);
	strErrMsg = RR.getErrMsg();
}
boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");

//if(vRetResult != null)
//	System.out.println(vRetResult.size());

boolean bolShowOnlyFinals = true;
if(WI.fillTextValue("show_other_grade").length() > 0) 
	bolShowOnlyFinals = false;
	
Vector vSubjectSummary = null;
///if show_no_of_stud is clicked i have to show # of student per subject. 
if(WI.fillTextValue("show_no_of_stud").length() > 0 && vRetResult != null && vRetResult.size() > 0 && 
	!WI.fillTextValue("report_type").equals("0")) 
	vSubjectSummary = (Vector)vRetResult.remove(0);
%>
<form action="./student_list_w_inc.jsp" method="post" name="report_registrar">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF STUDENTS PER GRADES STATUS ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
<%if(strSchCode.startsWith("DBTC") || strSchCode.startsWith("DBTC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:11px; color:#0000FF; font-weight:bold">
<%
if(bolIsBasic)
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="is_basic" value="1" <%=strTemp%> onClick="ReloadPage();"> Search Grade School </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td><%
strTemp = WI.fillTextValue("sy_from");
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	  
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("report_registrar","sy_from","sy_to")'>
to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");	  
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
- 
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
if(strTemp == null) 
	strTemp = "";
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
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:9px; color:#0000FF; font-weight:bold">
	<input type="checkbox" name="show_graduating" value="checked" <%=WI.fillTextValue("show_graduating")%>> Show Only Graduating Student
	&nbsp;&nbsp;
	 <input type="checkbox" name="show_other_grade" onClick="document.report_registrar.submit();" value="checked" <%=WI.fillTextValue("show_other_grade")%>> Show Other Grading Period (if not checked, system shows Final Grade) 
<%if(WI.fillTextValue("show_other_grade").length() > 0) {
if(bolIsBasic) 
	strTemp = "2 and bsc_grading_name is not null";
else	
	strTemp = "1 and exam_name not like 'final%'";
%>
        <select name="pmt_schedule">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_valid="+strTemp+" order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%> 
        </select>
<%}%>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"> <select name="report_type">
          <option value="0">Grades not yet encoded</option>
<%
if(WI.fillTextValue("report_type").equals("-1"))
	strTemp = " selected";
else	
	strTemp = "";
%>
		  <option value="-1" <%=strTemp%>>Grade encoded and having any remark</option>
<%
if(WI.fillTextValue("report_type").equals("-2"))
	strTemp = " selected";
else	
	strTemp = "";
%>
		  <option value="-2" <%=strTemp%>>All remarks except PASS</option>
          <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("report_type"), false)%> 
        </select> 
      <font size="1">(Grades not yet encoded works only for the stuents 
        enrolled in system)</font>
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  Number of Minimum <!--&quot;<strong><label id="gradeName">xyz</label></strong>&quot;--> Grade
      <input type="text" name="min_no" size="2" maxlength="2" value="<%=WI.fillTextValue("min_no")%>" class="textbox"
	   onKeyUp="AllowOnlyInteger('report_registrar','min_no');"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('report_registrar','min_no');style.backgroundColor='white'"> 
      <font size="1" color="#0000FF"><b>=&gt; for example, show student with min 3 failures</b></font></td>
    </tr>
<%if(!bolIsBasic){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="10%">Course</td>
      <td width="88%"><select name="course_index" onChange="loadMajor();">
          <option value="">Select a course</option>
          <%
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, WI.fillTextValue("course_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td>
	  <label id="load_major">
	  <select name="major_index">
          <option value=""> ALL </option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select>
	  </label>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Year </td>
      <td><select name="year_level">
        <option value="">No Filter</option>
        <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.equals("1")) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="1" <%=strErrMsg%>>1st</option>
        <%
if(strTemp.equals("2")) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="2"<%=strErrMsg%>>2nd</option>
        <%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="3"<%=strErrMsg%>>3rd</option>
        <%
if(strTemp.equals("4")) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="4"<%=strErrMsg%>>4th</option>
        <%
if(strTemp.equals("5")) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="5"<%=strErrMsg%>>5th</option>
        <%
if(strTemp.equals("6")) 
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="6"<%=strErrMsg%>>6th</option>
      </select></td>
    </tr>
<%}else{//basic.%>
	<tr >
	  <td height="25">&nbsp;</td>
	  <td width="10%">Grade Level </td>
	  <td width="88%"><select name="year_level" onChange="ReloadPage()">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("G_LEVEL","LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("year_level"),false)%>
      </select></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Student ID : 
        <input name="stud_id" type="text" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="26" height="24" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Print students whose lastname starts with 
        <select name="lname_from" onChange="ReloadPage()">
          <%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        to 
        <select name="lname_to">
          <option value="0"></option>
          <%
 strTemp = WI.fillTextValue("lname_to");
 
 for(int i=++j; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        &nbsp;&nbsp;&nbsp; <input type="image" src="../../../images/refresh.gif" onClick="ShowResult()"></td>
    </tr>
    <tr bgcolor="#999999">
      <td height="25">&nbsp;</td>
      <td colspan="2">Additonal Filter ::&nbsp;Section 
      <input name="section_" type="text" value="<%=WI.fillTextValue("section_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr bgcolor="#999999">
      <td height="25">&nbsp;</td>
      <td colspan="2">Subject Code : 
      <input name="subject_" type="text" value="<%=WI.fillTextValue("subject_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
      <font size="1">(starts with)</font>
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  Grade Range: 
	  
	  <input name="gr_fr" type="text" value="<%=WI.fillTextValue("gr_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="6"> 
	  to 
	  <input name="gr_to" type="text" value="<%=WI.fillTextValue("gr_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="6"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Sort Result (ascending) : 
	  <select name="s1">
	  <option value=""></option>
<%
strTemp = WI.fillTextValue("s1");
if(strTemp.equals("id_number"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="id_number"<%=strErrMsg%>>Student ID</option>
<%
if(strTemp.equals("lname"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="lname"<%=strErrMsg%>>Last Name</option>
<%
if(strTemp.equals("fname"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="fname"<%=strErrMsg%>>First Name</option>
	</select>
	  (default is by id_number)	  </td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){
int iMaxRow = 15;
if(WI.fillTextValue("report_type").equals("0"))
	iMaxRow = 12;
%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <TD colspan="2" style="font-size:11px; font-weight:bold">&nbsp;&nbsp; <u>Report Name : 
        <input name="report_name" type="text" value="<%=WI.fillTextValue("report_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateReportName();style.backgroundColor='white'" size="90" style="font-size:11px;">
      </u></TD>
    </tr>
    <tr> 
      <TD width="62%" style="font-size:11px">&nbsp;&nbsp;&nbsp;<strong>Total Subject Count : <%=vRetResult.size() /iMaxRow%></strong></TD>
      <TD width="38%" align="right"><a href='javascript:PrintPage();'> <img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print</font></TD>
    </tr>
    <tr>
      <TD colspan="2">
<%
strTemp = WI.fillTextValue("rem_course");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="rem_course" value="1" <%=strTemp%>>Remove Course information 
<%
strTemp = WI.fillTextValue("rem_fac");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>      <input type="checkbox" name="rem_fac" value="1" <%=strTemp%>>Remove Instructor information	  
<%
strTemp = WI.fillTextValue("show_grade");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>      <input type="checkbox" name="show_grade" value="1" <%=strTemp%>> Show Grade  
		<input type="checkbox" name="show_address" value="checked" <%=WI.fillTextValue("show_address")%>> Show Address  

	</TD>
    </tr>
<%
if((strSchCode.startsWith("CGH")) && !WI.fillTextValue("report_type").equals("0")){%>
    <tr>
      <TD colspan="2"><%
strTemp = WI.fillTextValue("rem_tc");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="rem_tc" value="1" <%=strTemp%>> Remove Student with TC
<%
strTemp = WI.fillTextValue("show_no_of_stud");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
      <input type="checkbox" name="show_no_of_stud" value="1" <%=strTemp%>> Show # of student per subject </TD>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="8" bgcolor="#FFFF99" class="thinborder" style="font-weight:bold"><div align="center">
	  <label id="report_n">LIST OF STUDENTS WITH GRADE STATUS : <%=WI.fillTextValue("report_type_name")%></label></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
      <td width="2%" class="thinborder" align="center"><strong><font size="1">Count</font></strong></td> 
      <td width="10%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Student ID </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>Student Name </strong></font></div></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">Subject Code </font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">Grade</font></strong></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>Course</strong></font></div></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>Section</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>Instructor</strong></font></td>
      <%if(bolShowOnlyFinals){%>
      <%}
strTemp = null;int iCount = 0;
boolean bolShowID = false;//show Name and show view icon.

for(int i = 0; i< vRetResult.size() ; i += iMaxRow){
bolShowID = false;
if(strTemp == null) {
	bolShowID = true;
	strTemp = (String)vRetResult.elementAt(i);
}
else {
	if(strTemp.compareTo(WI.getStrValue(vRetResult.elementAt(i))) != 0) {//id is different.
		bolShowID = true;
		strTemp = (String)vRetResult.elementAt(i);
	}

} %>
    <tr>
      <td class="thinborder">&nbsp;<%if(bolShowID){%><%=++iCount%>.<%}%></td> 
      <td height="25" class="thinborder">
	  <%if(bolShowID) {%>
	  <a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i)%>");'><%=(String)vRetResult.elementAt(i)%></a>
	  <%}else{%>&nbsp;<%}%>	  </td>
      <td class="thinborder">
	  <%if(bolShowID) {%>
	  <%=(String)vRetResult.elementAt(i + 1)%>
	  <%}else{%>&nbsp;<%}%>	  </td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">
	  	<%if(iMaxRow == 12){%>&nbsp;<%}else{%><%=WI.getStrValue(vRetResult.elementAt(i + 12), "&nbsp;")%><%}%>
	  </td>
      <td class="thinborder">
	  <%if(bolShowID) {%>
	  <%=(String)vRetResult.elementAt(i + 2)%>
	  <%if(vRetResult.elementAt(i + 3) != null){%>
	  /<%=(String)vRetResult.elementAt(i + 3)%>
	  <%}
	  }else{%>&nbsp;<%}%>	  </td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 11),"N/F")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 10),"N/F")%> </td>
      <%if(bolShowOnlyFinals){%>
      <%}%>
	</tr>
<%}%>
  </table>
<%if(vSubjectSummary != null && vSubjectSummary.size() > 0) {%><br>
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
        <tr bgcolor="#DDDDDD">
			<TD width="25%" class="thinborderBOTTOM">Subject Code </TD>
			<TD width="22%" class="thinborderBOTTOM"># of Student </TD>
			<TD class="thinborderBOTTOMRIGHT">&nbsp;</TD>
			<TD class="thinborderBOTTOM">&nbsp;</TD>
			<TD width="25%" class="thinborderBOTTOM">Subject Code </TD>
        	<TD width="22%" class="thinborderBOTTOM"># of Student</TD>
        </tr>
<%//iCount = 0;
for(int i =0; i < vSubjectSummary.size(); i += 2){//iCount += Integer.parseInt((String)vSubjectSummary.elementAt(i + 1));%>
        <tr>
          <TD class="thinborderNONE"><%=vSubjectSummary.elementAt(i)%></TD>
          <TD class="thinborderNONE"><%=vSubjectSummary.elementAt(i + 1)%></TD>
          <TD class="thinborderRIGHT">&nbsp;</TD>
          <TD class="thinborderNONE">&nbsp;</TD>
          <TD class="thinborderNONE">&nbsp;<%i = i +2; if(i < vSubjectSummary.size()){//iCount += Integer.parseInt((String)vSubjectSummary.elementAt(i + 1));%> <%=vSubjectSummary.elementAt(i)%><%}%></TD>
          <TD class="thinborderNONE">&nbsp;<%if(i < vSubjectSummary.size()){%> <%=vSubjectSummary.elementAt(i + 1)%><%}%></TD>
        </tr>
<%}//System.out.println(iCount);%>
 </table>
<%}%>

 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>

      <TD align="right"><a href='javascript:PrintPage();'> <img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print </font></TD>
        </tr>
 </table>

<%}//only if vRetResult not null
%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="showResult">
<input type="hidden" name="report_type_name">
<input type="hidden" name="remark_name" value="<%=WI.fillTextValue("remark_name")%>">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>