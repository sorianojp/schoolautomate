<%@ page language="java" import="utility.*, enrollment.AttendanceMonitoringCDD, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="javascript" src ="../../../jscript/common.js" ></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function ReloadPage()
{
	document.form_.search_.value = '1';
	document.form_.submit();
}

function PrintPg()
{	
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myTable3').deleteRow(0);
	document.getElementById('myTable3').deleteRow(0);
	
	window.print();
}


function OpenSearch(strUserType) {
	
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	if(strUserType == "0")
		pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
var strUser = "0";
//// - all about ajax.. 
function AjaxMapName(strUserType) {
		var strCompleteName = document.form_.stud_id.value;
		if(strUserType == "0")
			strCompleteName = document.form_.emp_id.value;
		if(strCompleteName.length < 2)
			return;
			
		strUser = strUserType
		
		var objCOAInput = document.getElementById("coa_info");
		if(strUserType == "0")
			objCOAInput = document.getElementById("coa_info_emp");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
		if(strUserType == "0")
			strURL += "&is_faculty=1";

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	
	if(strUser == "1")
		document.form_.stud_id.value = strID;
	else
		document.form_.emp_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	if(strUser == "1")
		document.getElementById("coa_info").innerHTML = "";
	else
		document.getElementById("coa_info_emp").innerHTML = "";
}

function ViewStudent(strUserIndex, strIDNumber){
    var pgLoc = "./student_absent_list.jsp?sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&offering_sem="+document.form_.offering_sem.value+		
		"&user_index="+strUserIndex+
		"&stud_id="+strIDNumber;			
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


</script>
</head>
<body bgcolor="#D2AE72">
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS-STUDENT TRACKER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"STUDENT AFFAIRS-STUDENT TRACKER","attendance_monitoring_report.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
Vector vRetResult = null;

enrollment.GradeSystem GS = new enrollment.GradeSystem();

AttendanceMonitoringCDD attendanceCDD = new AttendanceMonitoringCDD();
int iElemCount = 0;
if(WI.fillTextValue("search_").length() > 0){

	vRetResult = attendanceCDD.viewStudentDropList(dbOP, request);
	if(vRetResult == null)
		strErrMsg = attendanceCDD.getErrMsg();
	else
		iElemCount = attendanceCDD.getElemCount();

}

String strSYFrom = null;
String strSemester = null;
%>
<form action="./attendance_monitoring_report.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>::::
          ATTENDANCE MONITORING REPORT::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5">&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
	
	
	<tr>
		<td>&nbsp;</td>
		<td colspan="4">Click to display students with
		<%
		strTemp = WI.fillTextValue("show_unclaimed_cc");
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";		
		%>
				
			<input type="radio" name="show_unclaimed_cc" value="1" <%=strErrMsg%>> claimed classcards
		<%		
		if(strTemp.equals("2"))
			strErrMsg = "checked";
		else
			strErrMsg = "";	
		%>
				
			<input type="radio" name="show_unclaimed_cc" value="2" <%=strErrMsg%>> unclaimed classcards
		<%		
		if(strTemp.equals("3"))
			strErrMsg = "checked";
		else
			strErrMsg = "";		
		%>
			<input type="radio" name="show_unclaimed_cc" value="3" <%=strErrMsg%>> claimed/unclaimed classcards		</td>
	</tr>
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term</td>		
	  <td colspan="3">			
			<%
				strSYFrom = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strSYFrom%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%
			strSemester = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
			<select name="offering_sem">
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
            </select></td>
	</tr>
	
    <tr>
      <td height="25" width="3%"></td>
      <td width="15%">Student ID</td>
	  <%strTemp = WI.fillTextValue("stud_id");%>
      <td width="26%"><input name="stud_id" type="text" class="textbox" size="20" maxlength="20" value="<%=strTemp%>" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">        &nbsp; &nbsp; 
      	<a href="javascript:OpenSearch('1');"><img src="../../../images/search.gif" border="0" align="absmiddle"></a></td>
      <td width="56%">
	  <label id="coa_info" style="font-size:11px; width:400px; font-weight:bold; position:absolute; color:#0000FF"></label>	  </td>
    </tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<td colspan="2">
		<select name="course_index">
			<option value="">All</option>
			<%=dbOP.loadCombo("course_index","course_name, course_code", " from course_offered where is_valid = 1 and is_offered = 1 order by course_name", WI.fillTextValue("course_index"), false)%> 
		</select>		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Year Level  </td>
		<td colspan="2"><select name="year_level">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.length() == 0)
	strTemp = "";
	
if(strTemp.equals("1"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%> >1</option>
          <%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%> >2</option>
          <%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%> >3</option>
          <%
if(strTemp.equals("4"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
          <option value="4" <%=strErrMsg%> >4</option>
          <%
if(strTemp.equals("5"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
          <option value="5" <%=strErrMsg%> >5</option>
          <%
if(strTemp.equals("6"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>
          <option value="6" <%=strErrMsg%> >6</option>
        </select></td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Subjects </td>
		<%
		if(WI.getStrValue(strSYFrom).length() > 0 && WI.getStrValue(strSemester).length() > 0){
			strTemp = " from CDD_ATTENDANCE_MAIN join subject on (subject.sub_index = CDD_ATTENDANCE_MAIN.sub_index) " +
			" where CDD_ATTENDANCE_MAIN.is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
		}else{			
			strTemp = " from CDD_ATTENDANCE_MAIN join subject on (subject.sub_index = CDD_ATTENDANCE_MAIN.sub_index) " +
			" where CDD_ATTENDANCE_MAIN.is_valid = 1";
		}	
		
		%>
		<td colspan="2">
		<select name="sub_index" style="width:400px;">
			<option value="">All</option>
			<%=dbOP.loadCombo("distinct CDD_ATTENDANCE_MAIN.sub_index","sub_code, sub_name",  strTemp, WI.fillTextValue("sub_index"), false)%> 
		</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Faculty ID</td>
	    <td>
		<input name="emp_id" type="text" class="textbox" size="20" maxlength="20" value="<%=WI.fillTextValue("emp_id")%>" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('0');">        &nbsp; &nbsp; 
      	<a href="javascript:OpenSearch('0');"><img src="../../../images/search.gif" border="0" align="absmiddle"></a>		</td>
	    <td><label id="coa_info_emp" style="font-size:11px; width:400px; font-weight:bold; position:absolute; color:#0000FF"></label>	</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>No of Hours Absences</td>
	    <td colspan="2">
		<input name="hr_absences" type="text" size="4" maxlength="4" class="textbox" value="<%=WI.fillTextValue("hr_absences")%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hr_absences')"
				onKeyUp="AllowOnlyInteger('form_','hr_absences')">		</td>
	    </tr>
	
	
    <tr >
      <td height="25"></td>
      <td height="25">&nbsp;</td>
      <td colspan="3">
      <a href="javascript:ReloadPage();">
      <img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr >
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>
<%
if (vRetResult!= null && vRetResult.size()>0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable2">
	<tr><td align="right" valign="middle">	
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td></tr>
	<tr>
		<td align="right"><font size="1"><strong></strong></font><font size="1">Date and Time Printed: <%=WI.getTodaysDateTime()%></font>&nbsp;</td>
	</tr>
</table>


	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td class="thinborder" height="25" width="3%"><strong>Count</strong></td>
			<td class="thinborder" width="9%"><strong>Student ID</strong></td>
			<td class="thinborder" width="19%"><strong>Student Name</strong></td>
			<td class="thinborder" width="8%"><strong>Course</strong></td>
			
			<td class="thinborder" align="center" width="5%"><strong>Year Level</strong></td>
			<td class="thinborder" width="3%" align="center"><strong>Units</strong></td>
			<td class="thinborder" width="15%"><strong>Subject</strong></td>
			<td class="thinborder" width="10%"><strong>Section</strong></td>
			<td class="thinborder" width="14%"><strong>Instructor</strong></td>
			<td class="thinborder" align="center" width="5%"><strong>No. Of Hours Absences</strong></td>
			<td class="thinborder" align="center" width="9%"><strong>Class Card Status</strong></td>
		</tr>
		
		<%
		strTemp = "";
		String strColor = "";
		int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=iElemCount){			
		
		%>
		
		<tr onClick="ViewStudent('<%=(String)vRetResult.elementAt(i + 9)%>','<%=(String)vRetResult.elementAt(i)%>')">
			<td class="thinborder" height="25"><%=iCount++%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i),"&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
		  	<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"-","","")%></td>
			<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
			<%
			strTemp = GS.getLoadingForSubject(dbOP, (String)vRetResult.elementAt(i+13));
			%>
			<td class="thinborder" align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>			
			<td align="" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"-","","")%></td>
			<td align="" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;")%></td>
			<td align="" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),"&nbsp;")%></td>
			<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
		</tr>
		
		<%}%>
	</table>

<%}//end vRetResult not null%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable3">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
