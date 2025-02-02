<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>

<script language="JavaScript">

function ReloadPage(){
	document.form_.print_page.value = "";
	document.form_.submit();
}

function PrintReportAll(){	
	
		document.form_.get_stud_grade_list.value = "1";
		document.form_.print_page.value = "1";
		document.form_.submit();
}

function PrintReport(strUserIndex){	
	
	var strShowFail = "1";
	if( document.form_.show_only_fail.checked == false )
		strShowFail = "";
	

	var printLoc = "certificate_of_grade_print.jsp?get_stud_grade_list=1&user_index="+strUserIndex+
	"&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value+
	"&c_index="+document.form_.c_index.value+
	"&course_index="+document.form_.course_index.value+
	"&major_index="+document.form_.major_index.value+
	"&year_level="+document.form_.year_level.value+
	"&show_only_fail="+strShowFail+
	"&exam_period="+document.form_.exam_period.value;
	
	
	var win=window.open(printLoc,"PrintWindow",'width=800,height=400,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ShowReport(){
	document.form_.show_report.value = "1";
	this.ReloadPage();
}

function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.id_number.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.id_number.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	this.ReloadPage();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector, enrollment.ReportRegistrar " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./certificate_of_grade_print.jsp"></jsp:forward>
	<%return;}
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS",
								"certificate_of_grade.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"Registrar Management","REPORTS",
											request.getRemoteAddr(),
											"certificate_of_grade.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

String strSYFrom = WI.fillTextValue("sy_from");
String strSem    = WI.fillTextValue("semester");

String strCourseIndex = WI.fillTextValue("course_index");
String strMajorIndex  = WI.fillTextValue("major_index");
String strYearLevel   = WI.fillTextValue("year_level");

Vector vRetResult = null;

ReportRegistrar reportReg = new ReportRegistrar();

if(WI.fillTextValue("show_report").length() > 0){
	vRetResult = reportReg.getStudentListWithFailure(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportReg.getErrMsg();
}
//String strShowOnlyFail = "1";

//String strSchCode = dbOP.getSchoolIndex();
//boolean bolSPC = strSchCode.startsWith("SPC");
//if(bolSPC)
//	strShowOnlyFail = "";

%>

<form name="form_" action="certificate_of_grade.jsp" method="post" >

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="style3"><strong class="style3">::::
        CERTIFICATION OF GRADE  ::::</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong style="font-size:14px; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></strong>&nbsp;         </td>
      </tr>

    <tr>
        <td height="25">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("show_only_fail");
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
        <td colspan="2"><input type="checkbox" name="show_only_fail" value="1" <%=strErrMsg%>>Click to print failing grade(s) only.</td>
        </tr>
    <tr>
       <td width="3%">&nbsp;</td>      
      <td width="17%">&nbsp;&nbsp;SY-Term</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	
	
strSYFrom = strTemp;
//System.out.println((String)request.getSession(false).getAttribute("cur_sch_yr_from"));  
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
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
	
strSem = strTemp;
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
</select> </td>
    </tr>
    
	 <tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">&nbsp;&nbsp;College</td>
		<td><select name="c_index" style="width:400px;" onChange="ReloadPage();">
         <option value="">Select College</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">&nbsp;&nbsp;Course</td>
		<td>
		<%
		
		strErrMsg = WI.fillTextValue("course_index");
		strCourseIndex = strErrMsg;
		
		if(WI.fillTextValue("c_index").length() > 0)
		{
			strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and is_offered = 1 and c_index="+WI.fillTextValue("c_index")+
					" order by course_code asc" ;
		}
		else
			strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 order by course_code asc";
		%>
			<select name="course_index" style="width:400px;" onChange="ReloadPage();">
				<option value="">Select Course</option>
				<%=dbOP.loadCombo("course_index","course_code, course_name", strTemp, strErrMsg,false)%>
			</select>		</td>
	</tr>
	<tr>
	   <td height="25">&nbsp;</td>
	   <td>&nbsp; Major</td>
	   <td>
			<select name="major_index" onChange="ReloadPage();">
          <option value=""></option>
          <%
strErrMsg = WI.fillTextValue("major_index");
strMajorIndex = strErrMsg;

strTemp = WI.fillTextValue("course_index");
if(strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strErrMsg, false)%>
          <%}%>
        </select>		</td>
	   </tr>
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">&nbsp;&nbsp;Year Level</td>
		<td>
		<select name="year_level" onChange="ReloadPage();">
			<option value="">Select Year Level</option>
		<%
		strTemp = WI.fillTextValue("year_level");
		
		strYearLevel = strTemp;
		
		if(strTemp.equals("1"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="1" <%=strErrMsg%>>1st Year</option>
		<%
		if(strTemp.equals("2"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="2" <%=strErrMsg%>>2nd Year</option>
		<%
		if(strTemp.equals("3"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="3" <%=strErrMsg%>>3rd Year</option>
		<%
		if(strTemp.equals("4"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="4" <%=strErrMsg%>>4th Year</option>
		<%
		if(strTemp.equals("5"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="5" <%=strErrMsg%>>5th Year</option>
		<%
		if(strTemp.equals("6"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="6" <%=strErrMsg%>>6th Year</option>
		</select>		</td>
	</tr>
	
	
	
	
	<tr>
	   <td height="25">&nbsp;</td>
	   <td>&nbsp; Exam Period</td>
	   <td>
		<select name="exam_period" onChange="ReloadPage();">
          <option value="">Select Exam Period</option>
			 <%
			 strTemp = " from FA_PMT_SCHEDULE where IS_VALID = 1 order by EXAM_PERIOD_ORDER ";
			 %>
          <%=dbOP.loadCombo("pmt_sch_index","exam_name",strTemp, WI.fillTextValue("exam_period"), false)%>          
        </select>		</td>
	   </tr>
	<tr>
	   <td height="25">&nbsp;</td>
	   <td>&nbsp; ID Number</td>
	   <td>
			<input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	 		 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
			 <label id="coa_info" style=" position: absolute; font-size:11px; font-weight:bold; color:#0000FF; width:300px;"></label>		</td>
	 </tr>
	
	
	
	
	 <tr><td colspan="3">&nbsp;</td></tr>
	 <tr><td colspan="2">&nbsp;</td><td><input type="image" src="../../../../../images/form_proceed.gif" border="0" onClick="ShowReport();">
	 	<font size="1">Click to show list of student</font>
	 </td></tr>
  </table>
  
<%
if(vRetResult != null && vRetResult.size() > 0){

%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="right"><a href="javascript:PrintReportAll()"><img src="../../../../../images/print.gif" border="0"></a>
	<font size="1">Click to print all student</font></td></tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td align="center" colspan="5" height="22" class="thinborder"><strong>LIST OF STUDENT IF FAILING GRADE</strong></td>		
	</tr> 
	<tr>
		<td width="7%" align="center" class="thinborder"><strong>Count</strong></td>
		<td width="15%" height="20" class="thinborder"><strong>ID Number</strong></td>
		<td width="41%" height="20" class="thinborder"><strong>Student Name</strong></td>
		<td width="28%" height="20" class="thinborder"><strong>Course and Year Level</strong></td>
		<td width="9%" class="thinborder" align="center"><strong>PRINT</strong></td>
	</tr> 	
	
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+=20){%>
	<tr>
		<td class="thinborder" height="18" align="right"><%=iCount++%>.&nbsp;&nbsp;</td>
		<td class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
		<td class="thinborder"><%=strTemp%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+6)) + WI.getStrValue((String)vRetResult.elementAt(i+7)," major in ","","") + 
			WI.getStrValue((String)vRetResult.elementAt(i+8)," - ","","");
		%>
		<td class="thinborder"><%=strTemp%></td>
		<td class="thinborder" align="center">
			<a href="javascript:PrintReport('<%=vRetResult.elementAt(i)%>')"><img src="../../../../../images/print.gif" border="0"></a>
		</td>
	</tr>
	<%}%>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="right"><a href="javascript:PrintReportAll()"><img src="../../../../../images/print.gif" border="0"></a>
	<font size="1">Click to print all student</font></td></tr>
</table>
<%}%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="print_page" value="" >
<input type="hidden" name="show_report" value="" >
<input type="hidden" name="get_stud_grade_list" value="">
<!--<input type="hidden" name="show_only_fail" value="<%//=strShowOnlyFail%>">-->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
