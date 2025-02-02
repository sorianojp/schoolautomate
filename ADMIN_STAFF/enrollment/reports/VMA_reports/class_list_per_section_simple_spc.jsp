<%@ page language="java" import="utility.*,enrollment.VMAEnrollmentReports,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPage(){
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
			
	var obj1 = document.getElementById('myTable2');
	
	var oRows = obj1.getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i) 
		obj1.deleteRow(0);
	
	document.getElementById('myTable3').deleteRow(0);
	
	document.getElementById('myTable4').deleteRow(0);	
	document.getElementById('myTable4').deleteRow(0);
	
	window.print();

}

function Search(){
	if(document.form_.section_name.value == '' && (!document.form_.emp_id || document.form_.emp_id.selectedIndex == 0) ){
		alert("Please section section");
		return;
	}
	var strTemp = '';
	if(document.form_.course_index) {
		strTemp = document.form_.course_index[document.form_.course_index.selectedIndex].text;
		if(strTemp == 'All')
			strTemp = '';
	}
	document.form_.course_name.value = strTemp;	
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.form_.search_.value = '1';
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintEmptyGradeSheet(){
	var pgLoc = "./class_list_spc_cr_print.jsp";
	if(document.form_.emp_id.selectedIndex > 0)
		pgLoc = "./class_list_spc_cr_print_perfaculty.jsp";
	
	pgLoc += "?sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.offering_sem.value+
		"&emp_id="+document.form_.emp_id.value+
		"&section_name="+document.form_.section_name.value;
	var win=window.open(pgLoc,"releaseItems",'width=900,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	//alert(pgLoc);
	win.focus();
}	

/**
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
**/
</script>
<body bgcolor="#D2AE72">
<%
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	int iElemSubTotal = 0;
	int iHSSubTotal = 0;
	int iPreElemSubTotal = 0;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"class_list_per_section_simple_spc.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


VMAEnrollmentReports enrlReport = new VMAEnrollmentReports();
Vector vRetResult = new Vector();
Vector vFacultySection = new Vector();

boolean bolShowPerFaculty = false;

String strSYFrom      = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
String strSemester    = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
String strYearLevel   = null;
String strCourseIndex = null;

String strSectionName = WI.fillTextValue("section_name");

String[] astrConverSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", "4th Semester", "5th Semester"};

Vector vFacultyList = enrlReport.getListOfFacultyWithLoadSPC(dbOP, strSYFrom, strSemester);
if(vFacultyList == null) {
	strErrMsg = enrlReport.getErrMsg();
	vFacultyList = new Vector();
}
if(WI.fillTextValue("search_").length() > 0){
	if(WI.fillTextValue("section_name").length() == 0 && WI.fillTextValue("emp_id").length() > 0) {
		bolShowPerFaculty = true;
		vFacultySection = enrlReport.getSectionOfFaculty(dbOP, strSYFrom, strSemester,WI.fillTextValue("emp_id"));
		if(vFacultySection == null)
			strErrMsg = enrlReport.getErrMsg();
	}
	else {
		vRetResult = enrlReport.operateOnVMAEnrollmentReports(dbOP, request, 0);
		if(vRetResult == null)
			strErrMsg = enrlReport.getErrMsg();
		else {
			vFacultySection.addElement(null);//fake element.
			vFacultySection.addElement(null);//fake element.
		}
	}
}

%>
<form action="./class_list_per_section_simple_spc.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
	<tr bgcolor="#A49A6A">	
		<td width="100%" height="25" bgcolor="#A49A6A"><div align="center">
		<font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: CLASS LIST PER SECTION ::::</strong></font></div></td>
	</tr>
	<tr bgcolor="#FFFFFF"><td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term: </td>
		
		<td colspan="4">			
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strSYFrom%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'; document.form_.search_.value = '';document.form_.submit();"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = Integer.toString(Integer.parseInt(strSYFrom) + 1);
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<select name="offering_sem" onChange="document.form_.search_.value = '';document.form_.submit();">
			<%if(strSemester.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strSemester.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strSemester.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strSemester.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>	  </td>
	</tr>
<%if(WI.fillTextValue("emp_id").length() == 0) {%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<%
		strTemp = " where is_valid = 1 and is_offered = 1 order by course_code ";		
		%>
		<td colspan="4"> 
		<select name="course_index" onChange="document.form_.search_.value = '';document.form_.submit();">	
		<option value=""></option>	
		<%=dbOP.loadCombo("course_index","course_code, course_name", " from course_offered "+strTemp , WI.fillTextValue("course_index"), false)%> 
		</select>		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>		
		<td>Year</td>
		<td colspan="4">
		<select name="year_level" onChange="document.form_.search_.value = '';document.form_.submit();">
		<option value=""></option>
<%
strTemp = WI.fillTextValue("year_level");
if(strTemp.equals("1"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="1" <%=strErrMsg%>>1</option>
<%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="2" <%=strErrMsg%>>2</option>
<%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="3" <%=strErrMsg%>>3</option>
<%
if(strTemp.equals("4"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="4" <%=strErrMsg%>>4</option>
<%
if(strTemp.equals("5"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="5" <%=strErrMsg%>>5</option>
<%
if(strTemp.equals("6"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="6" <%=strErrMsg%>>6</option>			
		</select>		</td>
	</tr>
<%}%>

	<tr>
		<td height="25">&nbsp;</td>
		<td>Section</td>
		<%
		strErrMsg = "";
		strCourseIndex = WI.fillTextValue("course_index");
		strYearLevel = WI.fillTextValue("year_level");
		if(strCourseIndex.length() > 0)
			strErrMsg += " and course_index = "+strCourseIndex;
		if(strYearLevel.length() > 0)
			strErrMsg += " and year_level = "+strYearLevel;
		
		strTemp = " where is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester + strErrMsg;
		if(WI.fillTextValue("emp_id").length() > 0)
			strTemp += " and exists (select load_index from faculty_load join e_sub_section on (e_sub_section.sub_sec_index = faculty_load.sub_sec_index) "+
			"where section = section_name and offering_sy_from = sy_from and offering_sem = semester and faculty_load.is_valid = 1 and faculty_load.user_index = "+
			WI.fillTextValue("emp_id")+") ";
		//System.out.println(strTemp);
		%>
		<td colspan="2">
			<select name="section_name" onChange="document.form_.search_.value = '';document.form_.submit();">		
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("distinct section_name","section_name", " from stud_curriculum_hist "+strTemp +" order by stud_curriculum_hist.section_name", WI.fillTextValue("section_name"), false)%> 
			</select>		</td>
	</tr>
<!--
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Faculty ID </td>
	  <td>
	  <input name="emp_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=WI.fillTextValue("emp_id")%>" size="16">
	  <label id="coa_info" style="position:absolute; width:300px;"></label>
	  </td>
    </tr>
-->	
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Faculty ID </td>
	  <td width="47%">
	  <select name="emp_id" onChange="document.form_.search_.value = '';document.form_.submit();">
	  <option value=""></option>
<%
strTemp = WI.fillTextValue("emp_id");
for(int i = 0; i < vFacultyList.size(); i += 3) {
	if(strTemp.equals(vFacultyList.elementAt(i)))
		strErrMsg = " selected";
	else	
		strErrMsg = "";
%>
		<option value="<%=vFacultyList.elementAt(i)%>"<%=strErrMsg%>><%=vFacultyList.elementAt(i + 2)%> (<%=vFacultyList.elementAt(i + 1)%>)</option>
<%}%>
	  </select>	  </td>
      <td width="35%"> 
	  <%
	  if(WI.fillTextValue("emp_id").length() > 0 || WI.fillTextValue("section_name").length() > 0){
	  %>	
		<a href="javascript:PrintEmptyGradeSheet();"><img src="../../../../images/print.gif" border="0"></a>
		<font size="1">Click to print empty grade sheet</font>
	<%}%>
	  </td>
	</tr>
	<tr><td colspan="4">&nbsp;</td></tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td colspan="2"><a href="javascript:Search();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
	</tr>
</table>

<%
//if(vRetResult != null && vRetResult.size() > 0){
if(vFacultySection != null && vFacultySection.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable3">

	<tr><td align="right" colspan="3">
		<a href="javascript:PrintPage();">
		<img src="../../../../images/print.gif" border="0"></a></td></tr>
</table>
<%
while(vFacultySection.size() > 0) {
	if(bolShowPerFaculty) {
		//System.out.println(vFacultySection.elementAt(0));
		vRetResult = enrlReport.getClassListSPC(dbOP, strSYFrom, strSemester, (String)vFacultySection.remove(0));
		if(vRetResult == null) {
			vFacultySection.remove(0);
			continue;
		}
		strSectionName = (String)vFacultySection.remove(0);
	}
	else {
		vFacultySection.remove(0);vFacultySection.remove(0);
	}
		

	int iCount = 1;	
	String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
	String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,false);
	int iPageCount = 1;
	boolean bolIsPageBreak = false;
	//int iResultSize = 7;
	int iLineCount = 0;
	int iMaxLineCount = 60;	
	
	boolean bolPrintMale   = false;
	boolean bolPrintFemale = false;
	
	int i = 0;
	
	for(; i < vRetResult.size();){
		iLineCount = 0;
		
	%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr><td><div align="center"><strong><%=strSchoolName%></strong><br>
          <%=strSchoolAdd%><br>
		  </div></td></tr>
	<tr>
		<td colspan="" align="center" height="22" valign="bottom"><strong>CLASS LIST PER SECTION</strong></td>
    </tr>
	<tr>
		<td colspan="" align="center"><strong>
		<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>, 
		<%=astrConverSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="2"><strong>Section : <%=strSectionName%></strong></td>		
	</tr>
</table>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold">
		<td height="20" width="5%" align="center" class="thinborder" style="font-size:9px;"><strong>COUNT</strong></td>
		<td width="45%" align="center" class="thinborder" style="font-size:9px;"><strong>STUDENT NAME</strong></td>
		<td width="15%" align="center" class="thinborder" style="font-size:9px;"><strong>ID NUMBER</strong></td>
		<td width="12%" align="center" class="thinborder" style="font-size:9px;">COURSE-YR</td>
		<td width="8%" align="center" class="thinborder" style="font-size:9px;"><strong>STATUS</strong></td>
	</tr>

	<% 			
		for(; i < vRetResult.size();){			
			iLineCount++;		
	
		if(!bolPrintMale) {
			if(vRetResult.elementAt(i + 6).equals("M")) {
				bolPrintMale = true;%>
					<tr>
	  					<td height="18" colspan="5" class="thinborder" style="font-size:14px;">Male</td>
					</tr>
		<%}}
		if(!bolPrintFemale) {
			if(vRetResult.elementAt(i + 6).equals("F")) {
				bolPrintFemale = true;%>
					<tr>
						<td height="18" colspan="5" class="thinborder" style="font-size:14px;">Female</td>
					</tr>
		<%}}%>
	<tr>
		<td height="18" class="thinborder" style="font-size:9px;"><%=iCount++%></td>
		<td class="thinborder" style="font-size:9px;"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" style="font-size:9px;"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder" style="font-size:9px;"><%=(String)vRetResult.elementAt(i+8)%><%=WI.getStrValue((String)vRetResult.elementAt(i+9), "-","","")%></td>
		<td class="thinborder" style="font-size:9px;"><%=(String)vRetResult.elementAt(i+7)%></td>
	</tr>
		<%
			i+=10;
			if(iLineCount >= iMaxLineCount){
				bolIsPageBreak = true;
				break;		
			}else
				bolIsPageBreak = false;	
		%>
	
	<%}//end of for loop%>
</table>
  <%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>
<%}//end while loop%>
	
<%}//end vRetResult != null
  	if(vFacultySection.size() > 0){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}

}//while(vFacultySection.size() > 0) {%>
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>" />
<input type="hidden" name="course_name" value="<%=WI.fillTextValue("course_name")%>" />

</form>

 <!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div> 

</body>
</html>
<%
dbOP.cleanUP();
%>