<%
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,search.SearchStudent,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	
	}
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";

boolean bolMultipleEntry = WI.fillTextValue("multiple_entry").equals("1");
			
boolean bolPreventReload = false;
if(WI.fillTextValue("prevent_reload").length() > 0) 
	bolPreventReload = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript" src="../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.search_util.print_pg.value = "1";
	this.SubmitOnce("search_util");	
}
function ReloadPage()
{
	document.search_util.searchStudent.value = "";
	document.search_util.print_pg.value = "";
	this.SubmitOnce("search_util");
}
function SearchStudent()
{
	document.search_util.searchStudent.value = "1";
	document.search_util.print_pg.value = "";
	this.SubmitOnce("search_util");
}
function ViewDetail(strStudID)
{
//popup window here. 
	var pgLoc = "./stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function TogglePage(){
	document.search_util.shift_page_basic.value = "1";
	this.SubmitOnce("search_util");
}
function TogglePage2(){
	document.search_util.shift_page_basic.value = "2";
	this.SubmitOnce("search_util");
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strStudID)
{
	<%if(bolMultipleEntry){%>
		if(window.opener.document.<%=WI.fillTextValue("opner_info")%>.value.length > 0) 
			window.opener.document.<%=WI.fillTextValue("opner_info")%>.value+=","+strStudID;
		else	
			window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
		return;
	<%}else{%>
		window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
	<%}%>
	
	window.opener.focus();
	<%
	if(strFormName != null && !bolPreventReload){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	
	self.close();
}
<%}%>
function focusID() {
	document.search_util.id_number.focus();
}
function PrintAddress(strAddrIndex) {
	var strAddress = "";
	eval('strAddress = document.search_util.address'+strAddrIndex+'.value');
	if(strAddress.length == 0) {
		alert("Address is empty. - Failed to print.");
		return;
	}
	var pgLoc = "./print_address_envelopsize.jsp?address="+escape(strAddress);
	var vProceed = confirm("Click OK to print address in envelope size.");
	if(!vProceed)
		return;
	var win=window.open(pgLoc,"Printwindow",'width=400,height=200,top=100,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ChkShowOnlyEnrolled() {
	var strSYFrom = document.search_util.sy_from.value;
	if(strSYFrom.length != 4 && strSYFrom.length > 0) {
		alert("Please enter correct SY From Information.");
		document.search_util.sy_from.value = "";
		strSYFrom = "";
		document.search_util.sy_from.focus();
		//return;
	}
	if(strSYFrom.length == 0) 
		document.search_util.show_only_enrolled.checked = false;
}
function SearchHSGrad() {
	if(document.search_util.hs_grad.checked)
		document.search_util.status_index.selectedIndex=3;
	else	
		document.search_util.status_index.selectedIndex=0;
		
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	if (WI.fillTextValue("shift_page_basic").compareTo("1") == 0){
		response.sendRedirect(response.encodeRedirectURL("./srch_stud_basic.jsp?fs="+WI.fillTextValue("fs")));		
		return;
	}
// if this page is calling print page, i have to forward page to print page.
	if (WI.fillTextValue("shift_page_basic").compareTo("2") == 0){%>
		<jsp:forward page="./srch_stud_temp.jsp" />
	<%	return;
	}
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./srch_stud_print.jsp" />
	<%	return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Students","srch_stud.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=","<",">"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender","Course", "Year Level"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","course_name","yr"};


int iSearchResult = 0;

SearchStudent searchStud = new SearchStudent(request);
if(WI.fillTextValue("searchStudent").compareTo("1") == 0){
	vRetResult = searchStud.searchGeneric(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}

%>
<form action="./srch_stud_detail.jsp" method="post" name="search_util" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SEARCH STUDENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5"> <%
strTemp = WI.fillTextValue("show_only_enrolled");
if(strTemp.compareTo("1") == 0 || request.getParameter("gender") == null)
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_only_enrolled" value="1" <%=strTemp%>>
        Show only the students currently enrolled (please enter SY - Summer information)
		&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; <a href="./srch_stud.jsp?forced_=1&multiple_entry=<%=WI.fillTextValue("multiple_entry")%>&opner_info=<%=WI.fillTextValue("opner_info")%>">Go to Simple Search</a></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Student ID </td>
      <td width="10%"><select name="id_number_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="8%">Gender </td>
      <td width="42%"><select name="gender">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("F") == 0){%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}if(WI.fillTextValue("gender").compareTo("M") ==0){%>
          <option value="M" selected>Male</option>
          <%}else{%>
          <option value="M">Male</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td>
	  	<select name="lname_con">
        <%=searchStud.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select>	  </td>
      <td>
	  	<input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
      <td>SY-SEM</td>
      <td>
<%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else	
	strTemp = WI.fillTextValue("sy_from");
if(strTemp != null && strTemp.length() != 4)
	strTemp = "";
%>
	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="ChkShowOnlyEnrolled(); style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("search_util","sy_from","sy_to")' maxlength=4>
        to 
<%
if(strTemp != null && strTemp.length() > 0) 
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1) ;
else	
	strTemp = "";
%>
      <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly> &nbsp;&nbsp; <select name="semester">
          <option value="">N/A</option>
 <%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
else	
	strTemp = WI.fillTextValue("semester");
if(strTemp == null)
	strTemp = "";
		
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		   if (!strSchCode.startsWith("CPU")) {
		    if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Year Level</td>
      <td><select name="year_level">
          <option value="">N/A</option>
          <%
strTemp = WI.fillTextValue("year_level");
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
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course Prog </td>
      <td colspan="4"><select name="course_classification">
          <option value=""></option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from cclassification where IS_DEL=0 order by cc_name", request.getParameter("course_classification"), false)%> 
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="4">
	  <select name="college" onChange="ReloadPage();">
          <option value=""></option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name", request.getParameter("college"), false)%> 
        </select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="4">
	  <select name="course_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
		  								WI.getStrValue(WI.fillTextValue("college"), " and c_index=", "", "")+
										WI.getStrValue(WI.fillTextValue("course_classification"), " and cc_index=", "", "")+
 										" order by course_name asc", request.getParameter("course_index"), false)%> 
        </select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%if(strSchCode.startsWith("CGH")){%><font size="1" color="#0000FF">Section Name</font><%}else{%>Major<%}%></td>
      <td colspan="4">
	  <%if(strSchCode.startsWith("CGH")){//show section name. %>
	  	<input type="text" name="section_name" value="<%=WI.fillTextValue("section_name")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12">
	  <%}else{%>		
	  <select name="major_index">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("course_index").length()>0){
strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+" order by major_name asc";
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 							request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%> 
          <%}%>
        </select>
<%}%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student Status </td>
      <td colspan="4">
	          <select name="status_index" style="font-size:11px">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where is_for_student = 1 order by status asc",
					WI.fillTextValue("status_index"), false)%> </select>
		&nbsp;
		<input type="checkbox" name="show_only_irregular" value="checked" <%=WI.fillTextValue("show_only_irregular")%>> Show Irregular Stud	  
		<%if(strSchCode.startsWith("CIT") || strSchCode.startsWith("VMA") || true){%>
			<%if(strSchCode.startsWith("CIT")){%>
				&nbsp;
				<input type="checkbox" name="hs_grad" value="checked" <%=WI.fillTextValue("hs_grad")%> onClick="SearchHSGrad();"> Show HS Grad 
			<%}%> 
		&nbsp;
		<input type="checkbox" name="is_returnee" value="checked" <%=WI.fillTextValue("is_returnee")%>> Show Returnees Only.
		<%}%>		
		<%if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UB")){
			strTemp = WI.fillTextValue("is_graduating_stat");
			if(strTemp.equals("1")) {
				strTemp = " selected";
				strErrMsg = "";
			}
			else if(strTemp.equals("0")){
				strTemp = " ";
				strErrMsg = " selected";
			}
			%> &nbsp;&nbsp;&nbsp;
			<select name="is_graduating_stat">
				<option value=""></option>
				<option value="1"<%=strTemp%>>Show Only Grudating</option>
				<option value="0"<%=strErrMsg%>>Show Only Non-Graduating</option>
			</select>
		<%}%>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5"><input name="search_elem" type="checkbox" id="search_elem" value="1"  onClick="TogglePage()">
        Search elementary/high school students 
        <input name="search_temp" type="checkbox" value="1"  onClick="TogglePage2()">
        Search temporary student.</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderTOPLEFTRIGHT" bgcolor="#DDDDDD"> <%
strTemp = WI.fillTextValue("show_id");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
if(request.getParameter("print_pg") == null)
	strTemp = " checked";
%> <input type="checkbox" name="show_id" value="1"<%=strTemp%>>
        Show ID 
        <%
strTemp = WI.fillTextValue("show_gender");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
if(request.getParameter("print_pg") == null)
	strTemp = " checked";
%> <input type="checkbox" name="show_gender" value="1"<%=strTemp%>>
        Show Gender 
        <%
strTemp = WI.fillTextValue("show_dob");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_dob" value="1"<%=strTemp%>>
        Show DOB 
<%if(!strSchCode.startsWith("UI")){
strTemp = WI.fillTextValue("show_caddr");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="show_caddr" value="1"<%=strTemp%>> Show Current Address &nbsp;&nbsp;
<%
if(WI.fillTextValue("show_eaddr").compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="show_eaddr" value="1"<%=strTemp%>> Show Emergency Address &nbsp;&nbsp;
<%
if(WI.fillTextValue("show_haddr").compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="show_haddr" value="1"<%=strTemp%>> Show Home Address &nbsp;&nbsp;
<%}

strTemp = WI.fillTextValue("show_lastschool");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="show_lastschool" value="1"<%=strTemp%>>
        Show Last School Attended		
		&nbsp;&nbsp;
		<%if(strSchCode.startsWith("AUF") || strSchCode.startsWith("UC")){%>
			<input type="checkbox" value="checked" name="show_stud_emai_tel" <%=WI.fillTextValue("show_stud_emai_tel")%>>
			Show Student Email & Contact #
		<%}%>	  
		<%if(strSchCode.startsWith("FATIMA")){%>
			<input type="checkbox" value="checked" name="show_reg_irreg" <%=WI.fillTextValue("show_reg_irreg")%>>
			Show Student Status
		<%}%>	  
			<input type="checkbox" value="checked" name="show_cy_info" <%=WI.fillTextValue("show_cy_info")%>> Show Student Curriculum Year		
			<input type="checkbox" value="checked" name="show_father_info" <%=WI.fillTextValue("show_father_info")%>> Show Father Name		
			<input type="checkbox" value="checked" name="show_mother_info" <%=WI.fillTextValue("show_mother_info")%>> Show Mother Name		
		<%if(strSchCode.startsWith("UB")){%>
			<input type="checkbox" value="checked" name="show_tor_employment" <%=WI.fillTextValue("show_tor_employment")%>>
			Show TOR printed for Employemnet &nbsp;
			<input type="checkbox" value="checked" name="show_tor_boardexam" <%=WI.fillTextValue("show_tor_boardexam")%>>
			Show TOR printed for Board Exam
		<%}%>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderTOPLEFTRIGHT" bgcolor="#DDDDDD"> <%
strTemp = WI.fillTextValue("show_section");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_section" value="1"<%=strTemp%>>
        Show Section enrolled (shows only one section - useful only for block 
        section)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderLEFTRIGHT" bgcolor="#DDDDDD"> <%
strTemp = WI.fillTextValue("show_course");
if(strTemp.compareTo("1") == 0 || request.getParameter("print_pg") == null) // first time.
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_course" value="1"<%=strTemp%>>
        Show Course/Major 
        <%
strTemp = WI.fillTextValue("show_yr");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_yr" value="1"<%=strTemp%>>
        Show Year Level &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Name Format: 
        <select name="name_format" style="font-size:11px;font-weight:bold">
          <option value="4">lname, fname mi. (default)</option>
          <%
strTemp = WI.fillTextValue("name_format");
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>fname mname lname</option>
          <%}else{%>
          <option value="1">fname mname lname</option>
          <%}if(strTemp.compareTo("7") == 0) {%>
          <option value="7" selected>fname mi. lname</option>
          <%}else{%>
          <option value="7">fname mi. lname</option>
          <%}if(strTemp.compareTo("5") == 0) {%>
          <option value="5" selected>lname,fname mname</option>
          <%}else{%>
          <option value="5">lname,fname mname</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderLEFTRIGHT" bgcolor="#DDDDDD"> 
<%
strTemp = WI.fillTextValue("search_foreign");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="search_foreign" value="1"<%=strTemp%> onClick="document.search_util.search_foreign_gspis.checked=false;">
        Search only foreign student(Accounting) 
          <select name="alien_index" style="font-size:11px">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("ALIEN_NATIONALITY_INDEX","NATIONALITY"," from NA_ALIEN_NATIONALITY order by NATIONALITY", request.getParameter("alien_index"), false)%> 
        </select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;		
 <input type="checkbox" name="search_foreign_gspis" value="checked"<%=WI.fillTextValue("search_foreign_gspis")%> onClick="document.search_util.search_foreign.checked=false;">
        Search only foreign student(GSPIS) 
          <select name="alien_index_gspis" style="font-size:11px">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("nationality_index","nationality"," from HR_PRELOAD_NATIONALITY order by nationality", request.getParameter("alien_index_gspis"), false)%> 
        </select>		
		
		
		</td>
    </tr>
<%if(WI.fillTextValue("fs").length() > 0) {//show only fs search is called.
strTemp = WI.fillTextValue("fs_nodata");
if(strTemp.length() > 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderLEFTRIGHT" bgcolor="#DDDDDD">  <font color="#0000FF"><b> 
        <input type="checkbox" name="fs_nodata" value="1"<%=strTemp%>>
        Show Students without Finger Scan DATA</b></font>  </td>
    </tr>
<%}%>    
	<tr>
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderBOTTOMLEFTRIGHT" bgcolor="#DDDDDD">Date Enrolled: 
		  <input name="doe_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("doe_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('search_util.doe_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../images/calendar_new.gif" border="0"></a>
		
		to
		
		<input name="doe_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("doe_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('search_util.doe_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="27%">
	  <select name="sort_by1" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="28%"><select name="sort_by2" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="34%"><select name="sort_by3" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  	<input type="submit" name="1" value="&nbsp;&nbsp;Search&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.search_util.searchStudent.value='1';document.search_util.print_pg.value='';">	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" valign="top">Report Title: (use &lt;b&gt; bold text &lt;/b&gt; to make the title bold <br>        
	  	<textarea name="report_title" class="textbox" style="font-size:10px;" rows="4" cols="130"></textarea></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><%
	  if(WI.fillTextValue("opner_info").length() > 0){%>
        NOTE : Please click ID number to copy ID to form it is called from. 
        <%}%></td>
      <td width="27%" height="25">
	  <input name="per_course" type="checkbox" value="1">
      <font color="#0000FF" size="1">Print per college</font>&nbsp;
	  <!-- to break the pages. -->
	  <input name="rows_per_pg" type="text" class="textbox"	value="<%=WI.getStrValue(WI.fillTextValue("rows_per_pg"),"40")%>" 
	    onfocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyInteger('search_util','rows_per_pg')" 
		onKeyUp="AllowOnlyInteger('search_util','rows_per_pg')" size="2" maxlength="2">
	  
	  
	  </td>
      <td width="9%" align="right"><a href="javascript:PrintPg();"><img src="../images/print.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="64%" ><b> Total Students : <%=iSearchResult%> - Showing(<%=searchStud.getDisplayRange()%>)</b></td>
      <td colspan="2"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchStud.defSearchSize;
		if(iSearchResult % searchStud.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchStudent();">
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
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
<%
boolean bolShowCAddr = false; 
boolean bolShowHAddr = false; 
boolean bolShowEAddr = false; 
boolean bolShowLastSchool = false; 
boolean bolShowStudEmailTel = false;
boolean bolShowStudStat = false;
boolean bolShowCurYear  = false;

boolean bolShowFather  = false;
boolean bolShowMother  = false;

if(WI.fillTextValue("show_caddr").length() > 0) 
	bolShowCAddr = true;
if(WI.fillTextValue("show_eaddr").length() > 0) 
	bolShowEAddr = true;
if(WI.fillTextValue("show_haddr").length() > 0) 
	bolShowHAddr = true;
if(WI.fillTextValue("show_lastschool").length() > 0) 
	bolShowLastSchool = true;
if(WI.fillTextValue("show_stud_emai_tel").length() > 0) 
	bolShowStudEmailTel = true;
if(WI.fillTextValue("show_reg_irreg").length() > 0) 
	bolShowStudStat = true;
if(WI.fillTextValue("show_cy_info").length() > 0) 
	bolShowCurYear = true;
if(WI.fillTextValue("show_father_info").length() > 0) 
	bolShowFather = true;
if(WI.fillTextValue("show_mother_info").length() > 0) 
	bolShowMother = true;
	
%>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <%if(WI.fillTextValue("show_id").length() > 0) {%>
      <td  width="10%" height="25" ><div align="center"><strong><font size="1">Student ID </font></strong></div></td>
      <%}%>
      <td width="15%"><div align="center"><strong><font size="1">Last Name </font></strong></div></td>
      <td width="15%"><div align="center"><strong><font size="1">First Name </font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">MI</font></strong></div></td>
      <%if(WI.fillTextValue("show_gender").length() > 0) {%>
      	<td width="5%"><div align="center"><strong><font size="1">Gender</font></strong></div></td>
      <%}if(WI.fillTextValue("show_course").length() > 0) {%>
      	<td width="30%"><div align="center"><strong><font size="1">Course/Major</font></strong></div></td>
      <%}if(WI.fillTextValue("show_yr").length() > 0) {%>
      	<td width="5%"><div align="center"><strong><font size="1">Year</font></strong></div></td>
      <%}if(WI.fillTextValue("show_section").length() > 0) {%>
      <td width="5%"><div align="center"><strong><font size="1">Section</font></strong></div></td>
      <%}if(WI.fillTextValue("search_foreign").length() > 0 || WI.fillTextValue("search_foreign_gspis").length() > 0) {%>
      	<td width="5%"><div align="center"><strong><font size="1">Nationality</font></strong></div></td>
      <%}if(WI.fillTextValue("show_dob").length() > 0) {%>
 	     <td width="5%"><div align="center"><strong><font size="1">DOB</font></strong></div></td>
      <%}if(WI.fillTextValue("show_caddr").length() > 0) {%>
	      <td width="25%"><strong><font size="1">Current Address </font></strong></td>
      <%}if(WI.fillTextValue("show_haddr").length() > 0) {%>
	      <td width="25%"><strong><font size="1">Home Address </font></strong></td>
      <%}if(WI.fillTextValue("show_eaddr").length() > 0) {%>
	      <td width="25%"><strong><font size="1">Emergency Address </font></strong></td>
      <%}if(bolShowLastSchool){%>
	      <td width="30%" style="font-size:9px; font-weight:bold;" align="center">Last School Attended </td>
      <%}if(bolShowStudEmailTel){%>
		  <td width="13%" style="font-size:9px; font-weight:bold;" align="center">Student Email </td>
		  <td width="12%" style="font-size:9px; font-weight:bold;" align="center">Student mobile</td>
      <%}if(bolShowStudStat){%>
      	<td width="12%" style="font-size:9px; font-weight:bold;" align="center">Student Status </td>
<%}if(bolShowCurYear){%>
      <td width="12%" style="font-size:9px; font-weight:bold;" align="center">Curriculum Year </td>
<%}if(bolShowFather){%>
      <td width="12%" style="font-size:9px; font-weight:bold;" align="center">Father Name </td>
<%}if(bolShowMother){%>
      <td width="12%" style="font-size:9px; font-weight:bold;" align="center">Mother Name </td>
<%}%>
      <td width="5%"><div align="center"><strong><font size="1">View Detail </font></strong></div></td>
    </tr>
<%//System.out.println(vRetResult);
for(int i=0, j=0; i<vRetResult.size(); i+=26,++j){%>
    <tr> 
      <%if(WI.fillTextValue("show_id").length() > 0) {%>
      <td height="25" valign="top"><font size="1"> 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%> 
        <%}%>
        </font></td>
      <%}%>
      <td height="25" valign="top"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td valign="top"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td valign="top">&nbsp;<font size="1"> 
        <%if(vRetResult.elementAt(i+4) != null && ((String)vRetResult.elementAt(i+4)).length() > 0){%>
        <%=((String)vRetResult.elementAt(i+4)).charAt(0)%> 
        <%}%>
        </font></td>
      <%if(WI.fillTextValue("show_gender").length() > 0) {%>
      <td valign="top"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5),"n/f")%></font></td>
      <%}if(WI.fillTextValue("show_course").length() > 0) {%>
      <td valign="top"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+6)%> 
        <%
	  if(vRetResult.elementAt(i+7) != null){%>
        /<%=(String)vRetResult.elementAt(i+7)%> 
        <%}%>
        </font></td>
      <%}if(WI.fillTextValue("show_yr").length() > 0) {%>
      <td valign="top"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+8),"n/a")%></font></td>
      <%}if(WI.fillTextValue("show_section").length() > 0) {%>
      <td valign="top"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+9))%></font></td>
      <%}if(WI.fillTextValue("search_foreign").length() > 0 || WI.fillTextValue("search_foreign_gspis").length() > 0) {%>
      <td valign="top"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+10))%></font></td>
      <%}if(WI.fillTextValue("show_dob").length() > 0) {
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13));
		if(strTemp.length() > 0) {
			if(!strTemp.startsWith("10") && !strTemp.startsWith("11") && !strTemp.startsWith("12"))
				strTemp = "0"+strTemp;
		if(strTemp.length() == 9)
			strTemp = strTemp.substring(0,3)+"0"+strTemp.substring(3);
		}		
	  %>
      <td valign="top"><font size="1"><%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
<%}if(bolShowCAddr) {%>
		  <td><font size="1">
			<%=WI.getStrValue((String)vRetResult.elementAt(i+18),"<label onClick='PrintAddress("+j+")'>", "</label>", "&nbsp;")%></font>
		  <input type="hidden" name="address<%=j%>" value="<%=(String)vRetResult.elementAt(i+18)+"<br><br>"+
			WebInterface.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 
			(String)vRetResult.elementAt(i+2), 4).toUpperCase()%>">	  </td>
<%}if(bolShowHAddr) {%>
      	<td style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+22),"&nbsp;")%></td>
<%}if(bolShowEAddr) {%>
      	<td style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp;")%></td>
<%}if(bolShowLastSchool){%>
      <td style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"&nbsp;")%></td>
<%}if(bolShowStudEmailTel){%>
      <td style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+16),"&nbsp;")%></td>
      <td style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+17),"&nbsp;")%></td>
<%}if(bolShowStudStat){%>
      <td style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+19),"&nbsp;")%></td>
<%}if(bolShowCurYear){%>
      <td style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+20),"&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i+21),"-","","")%></td>
<%}if(bolShowFather){%>
      <td style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+24),"&nbsp;")%></td>
<%}if(bolShowMother){%>
      <td style="font-size:9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+25),"&nbsp;")%></td>
<%}%>
      <td align="center"><a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../images/view.gif" width="34" height="25" border="0"></a></td>
    </tr>
<%}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right"> </div></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../images/print.gif" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
  </table>
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="searchStudent" value="<%=WI.fillTextValue("searchStudent")%>">
<input type="hidden" name="print_pg">
<input type="hidden" name="shift_page_basic">
<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
<!-- search finger scan information -->
<input type="hidden" name="fs" value="<%=WI.fillTextValue("fs")%>">
<!-- 0 = simple search -->
<input type="hidden" name="search_type" value="1">

<!-- if multiple_entry=1 , there is multiple entry in the field, so
i have to append and do not close the window and no reloading of parent wnd -->
<input type="hidden" name="multiple_entry" value="<%=WI.fillTextValue("multiple_entry")%>">

<input type="hidden" name="prevent_reload" value="<%=WI.fillTextValue("prevent_reload")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>