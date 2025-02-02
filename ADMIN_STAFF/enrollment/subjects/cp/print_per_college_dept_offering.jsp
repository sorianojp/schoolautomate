<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Class Program</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/treelinkcss.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//strPrintStat = 0 = view only.
function ReloadPage()
{
	document.form_.form_proceed.value="";
	document.form_.submit();
}
function FormProceed()
{
	document.form_.form_proceed.value="1";
}

function loadDept() {
	var objCOA=document.getElementById("load_dept");
	var objCollegeInput = document.form_.c_index_sel[document.form_.c_index_sel.selectedIndex].value;
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index_sel&all=1";
	//alert(strURL);
	this.processRequest(strURL);
}
function PrintPg() {
	document.getElementById('myADTable2').deleteRow(0);
	var obj = document.getElementById('myADTable1');
	
	var oRows = obj.getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i)
		obj.deleteRow(0);
	
	alert("Click OK to print this report.");
	window.print();
}
function Toggle(i) {
	if(i == 0 && document.form_.per_open_close.checked) {
		document.form_.per_open_close1.checked = false;
		document.form_.per_open_close2.checked = false;
	}
	else if(i == 1 && document.form_.per_open_close1.checked) {
		document.form_.per_open_close.checked = false;
		document.form_.per_open_close2.checked = false;
	}
	else if(i == 2 && document.form_.per_open_close2.checked) {
		document.form_.per_open_close.checked = false;
		document.form_.per_open_close1.checked = false;
	}
	
	document.form_.submit();
	document.form_.per_open_close.disabled=true;
	document.form_.per_open_close1.disabled=true;
	document.form_.per_open_close2.disabled=true;
}

function FacultySched(strSubSecIndex, strLableID){
	if(strSubSecIndex == null || strSubSecIndex.length == 0){
		alert("Subject information reference is missing.");
		return;
	}
	
	var strCIndex = document.form_.c_index_sel.value;
	if(strCIndex == null || strCIndex.length == 0)
		strCIndex = "0";
	
	
	var strDIndex = "0";
	
	if(strCIndex != null && strCIndex.length > 0){
		strDIndex = document.form_.d_index_sel.value;
		if(strDIndex == null || strDIndex.length == 0)
			strDIndex = "0";
	}
	
	
		
	var strCollegeName = document.form_.c_index_sel[document.form_.c_index_sel.selectedIndex].text;
	
	var loadPg = "./redirect_form.jsp?sub_sec_index="+strSubSecIndex+
		"&c_c_index="+strCIndex+
		"&d_index="+strDIndex+"&college_name="+strCollegeName+"&faculty_lbl_id="+strLableID;
	var win=window.open(loadPg,"FacultySched",'dependent=yes,width=1100,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}


function LoadFacultyName(lblID, val)
{
	document.getElementById(lblID).innerHTML = val;
}
function ShowPerFaculty() {
	location = "./print_per_college_dept_offering_per_faculty.jsp";
}
</script>

<body bgcolor="#FFFFFF" topmargin='0' bottommargin='0'>
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	if(WI.fillTextValue("per_open_close").length() > 0 || WI.fillTextValue("per_open_close1").length() > 0 || WI.fillTextValue("per_open_close2").length() > 0) {%>
		<jsp:forward page="./print_per_college_dept_offering_open_close.jsp" />
	<%}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-print class program per college/dept offering","print_per_college_dept_offering.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														null);
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

SubjectSection SS = new SubjectSection();
Vector vRetResult = null;

if(WI.fillTextValue("form_proceed").compareTo("1") ==0)
{
	vRetResult = SS.printCPPerOfferingCollegeDept(dbOP,request, 0);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
}


boolean bolIsSplit = false;
if(WI.fillTextValue("split_conf_not_conf").length() > 0) 
	bolIsSplit = true;

boolean bolIsPerSubject = false;
if(WI.fillTextValue("show_persub").length() > 0) 
	bolIsPerSubject = true;
	
boolean bolShowLecLab = false;
Vector vSubLecLab = new Vector();//[0] sub_code, [1] lec_hr, [2] lab_hr

boolean bolShowPassFail = false;
if(WI.fillTextValue("show_passfailM").length() > 0 || WI.fillTextValue("show_passfailF").length() > 0) 
	bolShowPassFail = true;

String strSQLQuery = null;
java.sql.ResultSet rs = null;
double dTotalLecHr = 0d;
double dTotalLabHr = 0d;
Vector vLecLabHr   = new Vector();
String strLecHr    = null;
String strLabHr    = null;
int iTotalStud     = 0;

if(WI.fillTextValue("show_leclab").length() > 0 && vRetResult.size() > 0) {
	bolShowLecLab = true;
	strSQLQuery = "select distinct sub_code, hour_lec, hour_lab from curriculum join subject on (subject.sub_index = curriculum.sub_index) "+
					" where curriculum.is_valid = 1";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vLecLabHr.addElement(rs.getString(1));//[0] sub_code
		vLecLabHr.addElement(rs.getString(2));//[1] hour_lec
		vLecLabHr.addElement(rs.getString(3));//[2] hour_lab
	}
	rs.close();
}

Vector vPassFailInfo = new Vector();
if(vRetResult != null && bolShowPassFail) {
	vPassFailInfo = SS.getPassFailCIT(dbOP, request);
	if(vPassFailInfo == null)
		vPassFailInfo = new Vector();
}

%>
<form name="form_" action="./print_per_college_dept_offering.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr>
      <td height="25" colspan="3" align="center"><strong>:::: PRINT CLASS PROGRAM PER COLLEGE/DEPT OFFERING ::::</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td height="4">&nbsp;</td>
      <td width="48%" height="25" >Class program for school year : 
<%
strTemp = WI.fillTextValue("school_year_fr");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","school_year_fr","school_year_to")'> 
<%
strTemp = WI.fillTextValue("school_year_to");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        - 
        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td>Term 
        <select name="offering_sem">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Term</option>
          <%}else{%>
          <option value="1">1st Term</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Term</option>
          <%}else{%>
          <option value="2">2nd Term</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Term</option>
          <%}else{%>
          <option value="3">3rd Term</option>
          <%}%>
        </select>
		<%if(strSchCode.startsWith("CIT")){%>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="javascript:ShowPerFaculty()">
				Show Per Faculty (Sort by Faculty)			</a>
		<%}%>		</td>
    </tr>
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    
    <tr> 
      <td width="2%" height="4">&nbsp;</td>
      <td height="25">Offering College </td>
      <td width="50%">Offering Department 
      </td>
    </tr>
    <tr> 
      <td width="2%" height="3">&nbsp;</td>
      <td><select name="c_index_sel" onChange="loadDept();">
	  <option value=""></option>
	  	<%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index_sel"), false)%>
	  </select></td>
	  <%
	  strTemp = " from department where IS_DEL=0 and (c_index = 0 or c_index is null ) order by d_name asc";
	  if(WI.fillTextValue("c_index_sel").length() > 0)
		  strTemp = " from department where IS_DEL=0 and c_index = "+WI.fillTextValue("c_index_sel")+" order by d_name asc";
	  %>
      <td>
	  <label id="load_dept">
	    <select name="d_index_sel">
			  <option value="">ALL</option>
			  <%=dbOP.loadCombo("d_index","d_name", strTemp, WI.fillTextValue("d_index_sel"), false)%>
		</select> <input type="checkbox" name="show_dept_null" value="selected" <%=WI.fillTextvalue("show_dept_null")%>> Show only having no department
</label></td>
    </tr>
<%if(strSchCode.startsWith("CIT")){%>
    <tr valign="top">
      <td height="3">&nbsp;</td>
      <td style="font-weight:bold; font-size:11px; color:#0000FF">
	  	<input type="checkbox" name="is_count_restricted" value="checked" <%=WI.fillTextValue("is_count_restricted")%> onClick="ReloadPage();"> Restrict Enrolled Student Count
	  <%if(WI.fillTextValue("is_count_restricted").length() > 0){%>
	  	<br>
		<a href="javascript:ReloadPage();"><img src="../../../../images/refresh.gif" border="0"><font style="font-size:9px; font-weight:normal; color:#000000"> Reload the list of course</font>
	  <%}%>
	  </td>
      <td>
<%
Vector vCourseRestricted = new Vector();
int iRestrictedCourseCount = 0; int iIncr = 0;
if(WI.fillTextValue("is_count_restricted").length() > 0 && WI.fillTextValue("c_index_sel").length() > 0) {
	strSQLQuery = "select course_index,course_code from course_offered where c_index = "+WI.fillTextValue("c_index_sel");
	if(WI.fillTextValue("d_index_sel").length() > 0) 
		strSQLQuery += " and d_index = "+WI.fillTextValue("d_index_sel");
	strSQLQuery +=" and is_valid = 1 order by course_code";
	//System.out.prinltn(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vCourseRestricted.addElement(rs.getString(1));
		vCourseRestricted.addElement(rs.getString(2));
		++iRestrictedCourseCount;
	}
	rs.close();
}if(vCourseRestricted.size() > 0) {%>
	<div style="width:400px; height:60px; font-size:9px;overflow: auto; border: inset black 1px" >
		<table width="100%" cellpadding="0" cellspacing="0">
		<%while(vCourseRestricted.size() > 0) {%>
			<tr>
				<td width="34%" style="font-size:9px;"><input type="checkbox" name="_<%=iIncr++%>" value="<%=vCourseRestricted.remove(0)%>"> <%=vCourseRestricted.remove(0)%></td>
				<td width="33%" style="font-size:9px;"><%if(vCourseRestricted.size() > 0) {%><input type="checkbox" name="_<%=iIncr++%>" value="<%=vCourseRestricted.remove(0)%>"> <%=vCourseRestricted.remove(0)%><%}%></td>
				<td width="33%" style="font-size:9px;"><%if(vCourseRestricted.size() > 0) {%><input type="checkbox" name="_<%=iIncr++%>" value="<%=vCourseRestricted.remove(0)%>"> <%=vCourseRestricted.remove(0)%><%}%></td>
			</tr>
		<%}%>	
		</table>
	</div>
<%}%> 

<input type="hidden" name="restricted_course_count" value="<%=iRestrictedCourseCount%>">
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="3">&nbsp;</td>
      <td style="font-weight:bold; font-size:11px; color:#0000FF">
<%if(WI.fillTextValue("is_registrar").length() > 0) {%>
	  	<input type="checkbox" name="show_passfailM" value="checked" <%=WI.fillTextValue("show_passfail")%>> Show Pass/Fail(M) 
	  	<input type="checkbox" name="show_passfailF" value="checked" <%=WI.fillTextValue("show_passfail")%>> Show Pass/Fail(F)
<%}else{%>
	  <input type="checkbox" name="show_persub" value="checked" <%=WI.fillTextValue("show_persub")%>> Show Per Subject 
	  <input type="checkbox" name="show_faculty" value="checked" <%=WI.fillTextValue("show_faculty")%>> Show Faculty 
	  <input type="checkbox" name="show_leclab" value="checked" <%=WI.fillTextValue("show_leclab")%>> Show Lec/Lab 
<%if(strSchCode.startsWith("CIT")){%>
		<br>
	  	<input type="checkbox" name="less_20" value="checked" <%=WI.fillTextValue("less_20")%>> Show Less 20 	  	 
	  	<!--<input type="checkbox" name="sort_by_fac" value="checked" <%=WI.fillTextValue("sort_by_fac")%>> Sort by Faculty -->	  	 
	<br>
	<input type="textbox" name="stud_count" value="<%=WI.fillTextValue("stud_count")%>" class="textbox" size="4"> 
	Student Count(enter in format <20,>56,=45)
    <%}
}%>	</td>
      <td style="font-weight:bold; font-size:11px; color:#0000FF">
<%if(WI.fillTextValue("is_registrar").length() == 0) {%>
	  	<input type="checkbox" name="per_open_close" value="checked" <%=WI.fillTextValue("per_open_close")%> onClick="Toggle(0);"> Print Per Open/Close 
	  	&nbsp;&nbsp;&nbsp;
	  	<input type="checkbox" name="per_open_close1" value="checked" <%=WI.fillTextValue("per_open_close1")%> onClick="Toggle(1);"> Print Open Only 
	  	&nbsp;&nbsp;&nbsp;
	  	<input type="checkbox" name="per_open_close2" value="checked" <%=WI.fillTextValue("per_open_close2")%> onClick="Toggle(2);"> Print Close Only
<%}

if(false){%>
	  	&nbsp;&nbsp;&nbsp;
			<input type="checkbox" name="split_conf_not_conf" value="checked" <%=WI.fillTextValue("split_conf_not_conf")%>> Split Confirmed and Not Confirmed 
<%}%>	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2" align="center"><br>
        <input name="image" type="image" onClick="FormProceed();" src="../../../../images/form_proceed.gif">      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><div align="center"></div></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
String strDateTimePrinted = WI.formatDateTime(new java.util.Date(), 5);
int iNoOfRowsPerPg = 30;
if(WI.fillTextValue("offering_sem").equals("0"))
	iNoOfRowsPerPg = 35;
boolean bolOrderByFac = false;
if(WI.fillTextValue("sort_by_fac").length() > 0 || WI.fillTextValue("is_count_restricted").length() > 0) 
	iNoOfRowsPerPg = 1000000;

int iCurRow = 0, iPageNo = 0; int iTotCount = 0; boolean bolShowInstructor = false;
if(WI.fillTextValue("show_faculty").length() > 0)
	bolShowInstructor = true;

String strCollegeName = null;
String strDeptName    = null;
Vector vTemp = null; String strTemp2 = null; int iIndexOf = 0;

String strIsLec = null;

if(WI.fillTextValue("c_index_sel").length() > 0) { 
	strSQLQuery = "select c_name from college where c_index = "+WI.fillTextValue("c_index_sel");
	strCollegeName = dbOP.getResultOfAQuery(strSQLQuery, 0);
}

if(WI.fillTextValue("d_index_sel").length() > 0) {
	strSQLQuery = "select d_name from department where d_index = "+WI.fillTextValue("d_index_sel");
	strDeptName = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strDeptName != null)
		strDeptName = strDeptName.toUpperCase();
}
if(strCollegeName != null)
	strCollegeName = strCollegeName.toUpperCase() + WI.getStrValue(strDeptName, " - ", "","");

String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"}; 

if(vRetResult != null && vRetResult.size() > 0){%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
			<tr>
			  <td align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>Pring Page.</td>
			</tr>
		  </table>
<%	
int iLabelCount = 1;
for(int i = 0; i < vRetResult.size();){
		if(i > 0) {%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<%}
		iCurRow = 0;
		%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
			  <td>Date Printed: <%=strDateTimePrinted%></td>
			  <td align="right">Page: <%=++iPageNo%></td>
			</tr>
			<tr>
			  <td colspan="2" align="center"><%=WI.getStrValue(strCollegeName)%></td>
			</tr>
			<tr>
			  <td colspan="2" align="center">SUBJECT OFFERINGS</td>
			</tr>
			<tr>
			  <td colspan="2" align="center"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, SY <%=WI.fillTextValue("school_year_fr")%> - <%=WI.fillTextValue("school_year_to")%></td>
			</tr>
		  </table>
		  	<%if(bolIsPerSubject){%>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr style="font-weight:bold"> 
			  <td width="1%" height="24" class="thinborderTOPBOTTOM">&nbsp;</td>
			  <td width="26%" class="thinborderTOPBOTTOM">Subject Code </td>
			  <td width="52%" class="thinborderTOPBOTTOM">Descriptive Title </td>
			  <td width="9%" class="thinborderTOPBOTTOM">Units</td>
			  <td width="12%" class="thinborderTOPBOTTOM">Student Enrolled </td>
			</tr>
		<%
		for(; i < vRetResult.size(); i += 5) {%>
			<tr valign="top">
			  <td height="24">&nbsp;</td>
			  <td><%=vRetResult.elementAt(i + 1)%></td>
			  <td><%=vRetResult.elementAt(i + 2)%></td>
			  <td><%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></td>
			  <td><%=WI.getStrValue(vRetResult.elementAt(i + 4),"&nbsp;")%></td>
			</tr>
		<%
			if(++iCurRow > iNoOfRowsPerPg) {
				i += 5;
				break;
			}
		}%>
		  </table>
			<%}else{%>	 
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr style="font-weight:bold"> 
			  <td width="2%" height="24" class="thinborderTOPBOTTOM">&nbsp;</td>
			  <td width="15%" class="thinborderTOPBOTTOM">Code - Section </td>
<%if(!bolShowInstructor){%>
			  <td width="25%" class="thinborderTOPBOTTOM">Descriptive Title </td>
<%}%>			 
			  <td width="5%" class="thinborderTOPBOTTOM">Units</td>
			  <td width="23%" class="thinborderTOPBOTTOM">Schedule</td>
			  <td width="5%" class="thinborderTOPBOTTOM">Room</td>
			  <td width="5%" class="thinborderTOPBOTTOM">Limit</td>
			  <td width="5%" class="thinborderTOPBOTTOM">Qty</td>
<%if(bolIsSplit) {%>
              <td width="5%" class="thinborderTOPBOTTOM">Conf</td>
              <td width="5%" class="thinborderTOPBOTTOM">Not Conf </td>
<%}if(bolShowInstructor){%>
			  <td width="25%" class="thinborderTOPBOTTOM">Instructor</td>
	<%if(strSchCode.startsWith("CIT")){%>
			  <td width="15%" class="thinborderTOPBOTTOM">Remarks</td>
	<%}
}if(bolShowLecLab){%>
              <td width="5%" class="thinborderTOPBOTTOM">Lec Hr</td>
              <td width="5%" class="thinborderTOPBOTTOM">Lab Hr</td>
<%}if(bolShowPassFail){%>
              <td width="5%" class="thinborderTOPBOTTOM">Pass</td>
              <td width="5%" class="thinborderTOPBOTTOM">Fail</td>
<!--
              <td width="5%" class="thinborderTOPBOTTOM">Not Encoded </td>
-->
<%}%>
			</tr>
		<%
		for(; i < vRetResult.size(); i += 17) {
			strTemp = (String)vRetResult.elementAt(i + 8);
			if(strTemp != null && strTemp.indexOf("<br>") > 1)
				++iCurRow;
			//limit the subject name size to 30
			strTemp = (String)vRetResult.elementAt(i + 2);
			if(strTemp != null && strTemp.length() > 30)
				strTemp = strTemp.substring(0, 30);
			//this coded is added to swap the Days to end of time. now it is MWF 8 am to 9am :: CIT wants 8 am to 9am MWF.	
			strErrMsg = (String)vRetResult.elementAt(i + 8);
			if(strErrMsg != null) {
				vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);
				strErrMsg = "";
				while(vTemp.size() > 0) {
					strTemp2 = (String)vTemp.remove(0);
					iIndexOf = strTemp2.indexOf(" ");
					if(iIndexOf > -1)
						strTemp2 = strTemp2.substring(iIndexOf).toLowerCase() +  " &nbsp;" + strTemp2.substring(0, iIndexOf);
					if(strErrMsg.length() > 0) 
						strErrMsg = strErrMsg + "<br>";
					strErrMsg = strErrMsg +strTemp2;
				}
			}
			//end of swapping.
			
			//check if lab subject.. 
			if(vRetResult.elementAt(i + 14).equals("1"))
				strIsLec = " (Lab)";
			else {	
				strIsLec = "";
				++iTotCount;//only if lec.. 
			}
		%>
			<tr valign="top">
			  <td height="24">&nbsp;</td>
			  <td><%if(strIsLec.length() == 0) {%><%=vRetResult.elementAt(i + 1)%> - <%=vRetResult.elementAt(i + 4)%><%}%></td>
<%if(!bolShowInstructor){%>
			  <td><%if(strIsLec.length() == 0) {%><%=strTemp%><%}%></td>
<%}%>
			  <td><%if(strIsLec.length() == 0) {%><%=vRetResult.elementAt(i + 12)%><%}else{%><div align="right">LAB&nbsp;</div><%}%></td>
			  <td><%=strErrMsg%></td>
			  <td><%=vRetResult.elementAt(i + 10)%></td>
			  <td><%=WI.getStrValue(vRetResult.elementAt(i + 5),"&nbsp;")%></td>
			  <%
			  try{
			  	iTotalStud += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i + 13),"0"));
			  }catch(Exception e){}
			  %>
			  <td><%=WI.getStrValue(vRetResult.elementAt(i + 13),"&nbsp;")%></td>
<%if(bolIsSplit) {%>
              <td><%=WI.getStrValue(vRetResult.elementAt(i + 15),"&nbsp;")%></td>
              <td><%=WI.getStrValue(vRetResult.elementAt(i + 16),"&nbsp;")%></td>
<%}if(bolShowInstructor){
strTemp = WI.getStrValue(vRetResult.elementAt(i + 11), " ______________ ");
if(strTemp.length() > 32)
	strTemp = strTemp.substring(0, 32);
%>
			  <td><input type="hidden" name="test_test"><a href="javascript:FacultySched('<%=vRetResult.elementAt(i)%>', 'lbl_faculty_name<%=iLabelCount%>')">
			  	<label id="lbl_faculty_name<%=iLabelCount++%>"><%=strTemp%></label></a></td>
				
	<%if(strSchCode.startsWith("CIT")){%>
			  <td width="15%"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
	<%}			
				
}if(bolShowLecLab && strIsLec.length() == 0){
iIndexOf =vLecLabHr.indexOf(vRetResult.elementAt(i + 1));
///as per request, i will not show lec/lab hour for dissolved / if no student enrolled
if(vRetResult.elementAt(i + 10).equals("DISSOLVED") || WI.getStrValue(vRetResult.elementAt(i + 15)).length() == 0 ) {
			strLecHr    = "&nbsp;";
			strLabHr    = "&nbsp;";
}
else {
	if(iIndexOf == -1) {
		if(vRetResult.elementAt(i + 12) == null) {
			strLecHr    = "&nbsp;";
			strLabHr    = "&nbsp;";
		}
		else {
			strLecHr    = (String)vRetResult.elementAt(i + 12);
			strLabHr    = "0";
			dTotalLecHr += Double.parseDouble(WI.getStrValue(strLecHr, "0"));
			dTotalLabHr += Double.parseDouble(WI.getStrValue(strLabHr, "0"));
		}
		
	}
	else {
		strLecHr    = (String)vLecLabHr.elementAt(iIndexOf + 1);
		strLabHr    = (String)vLecLabHr.elementAt(iIndexOf + 2);
		dTotalLecHr += Double.parseDouble(WI.getStrValue(strLecHr, "0"));
		dTotalLabHr += Double.parseDouble(WI.getStrValue(strLabHr, "0"));
	} 
}
%>
             <td><%=WI.getStrValue(strLecHr,"&nbsp;")%></td>
             <td><%=WI.getStrValue(strLabHr,"&nbsp;")%></td>
<%}if(bolShowPassFail){
iIndexOf = vPassFailInfo.indexOf(vRetResult.elementAt(i));
if(iIndexOf == -1)
	strTemp = "&nbsp;";
else {
	if(vPassFailInfo.elementAt(iIndexOf + 1).equals("1")) {
		vPassFailInfo.remove(iIndexOf);vPassFailInfo.remove(iIndexOf);
		strTemp = (String)vPassFailInfo.remove(iIndexOf);
	}
	else 
		strTemp = "&nbsp;";
}
%>
             <td><%=strTemp%></td>
<%
iIndexOf = vPassFailInfo.indexOf(vRetResult.elementAt(i));
if(iIndexOf == -1)
	strTemp = "&nbsp;";
else {
	if(vPassFailInfo.elementAt(iIndexOf + 1).equals("0")) {
		vPassFailInfo.remove(iIndexOf);vPassFailInfo.remove(iIndexOf);
		strTemp = (String)vPassFailInfo.remove(iIndexOf);
	}
	else 
		strTemp = "&nbsp;";
}
%>
             <td><%=strTemp%></td>
<%
iIndexOf = vPassFailInfo.indexOf(vRetResult.elementAt(i));
if(iIndexOf == -1)
	strTemp = "&nbsp;";
else {
	if(vPassFailInfo.elementAt(iIndexOf + 1).equals("-1")) {
		vPassFailInfo.remove(iIndexOf);vPassFailInfo.remove(iIndexOf);
		strTemp = (String)vPassFailInfo.remove(iIndexOf);
	}
	else 
		strTemp = "&nbsp;";
}
%>             <!--<td><%=strTemp%></td>-->
<%}%>
			</tr>
		<%
			if(++iCurRow > iNoOfRowsPerPg) {
				i += 17;
				break;
			}
		}%>
		  </table>
		  	<%}%>
		  
	<%}//for loop to show the pages.%>
	<%if(!bolIsPerSubject){%>
		<br>
		<b><font style="font-size:14px;">Total Number of Subjects/Sections: <%=iTotCount%></font></b>
	<%}%>
	<%if(bolShowLecLab){%>
		<br>
		<b><font style="font-size:14px;">Total Lec: <%=dTotalLecHr%>, Total Lab: <%=dTotalLabHr%></font></b>
	<%}
	
	if(strSchCode.startsWith("CIT") && iTotalStud > 0){
	%>
		<br>
		<b><font style="font-size:14px;">Total Students: <%=iTotalStud%></font></b>
	<%}%>
	
<%}//only if vSecList.size()>0%>

<input type="hidden" name="form_proceed">
<input type="hidden" name="is_registrar" value="<%=WI.fillTextValue("is_registrar")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
