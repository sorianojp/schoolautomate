<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg(){
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);	document.getElementById('myADTable4').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);	
	
	alert("Click OK to print this page");
	window.print();
}
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function Search(){	
	document.form_.search_.value = '1';
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Enrollment","STATISTICS",request.getRemoteAddr(),
							//							"statistics_enrollees.jsp");
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
ReportEnrollment RE = new ReportEnrollment();
Vector vRetResult = null;

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = RE.operateOnDissolvedSubject(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RE.getErrMsg();
	
}

	
String strSYFrom = null;
String strSemester = null;
%>
<form action="dissolved_subject_list.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LISTS OF DISSOLVED SUBJECTS ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td height="25"></td>
      <td colspan="2" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    
    
    
    <tr> 
      <td height="25"></td>
      <td height="25" colspan="2"><strong>Offering School Year/Term</strong></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td height="25" colspan="2"> 
	<%strSYFrom = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));%> 
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
	<%strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));%> 
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="1">1st Sem</option>
          <%
	strSemester = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
	if(strSemester.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strSemester.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strSemester.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strSemester.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td height="25" colspan="2" valign="bottom"><strong>Show By :</strong></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>Specific ID</td>
      <td><input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" height="25"></a></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="20%">College/School</td>
      <td width="76%"><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
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
		<td height="25">&nbsp;</td>
		<td>Section</td>
		
		<%
		
		strTemp = " from e_sub_section where is_valid = 1 and is_dissolved = 1 and exists (select * from subject where sub_index = e_sub_section.sub_index and is_del = 0) "+
				" and offering_sy_from = "+strSYFrom+" and offering_sem = "+strSemester;
		%>
				
		<td colspan="2">
			<select name="section_name">		
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("distinct section","section", strTemp , WI.fillTextValue("section_name"), false)%> 
			</select>
		</td>
	</tr>
    <tr> 
      <td height="25"></td>
      <td>&nbsp;</td>
      <td><input name="image" type="image" onClick="Search();" src="../../../images/form_proceed.gif">
	  
	  <input type="checkbox" name="remove_student" value="checked" <%=WI.fillTextValue("remove_student")%>> 
	  <font style="font-size:9px; font-weight:bold; color:#0000FF"> Remove Student</font>
	  
	  </td>
    </tr>
    <tr> 
      <td height="10"></td>
      <td></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  
  
  
  
  
  
  
  
<%
Vector vStudList = new Vector();
boolean bolRemoveStudent = false;
if(WI.fillTextValue("remove_student").length() > 0) 
	bolRemoveStudent = true;
boolean bolPrintHeader = true;

if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable3">
<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a></td></tr>
<tr><td><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div></td></tr>
<tr><td height="20" align="center"><strong>LIST OF DISSOLVED SUBJECTS</strong></td></tr>
</table>



<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
	
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+=11, iCount++){//outer loop
		vStudList = (Vector)vRetResult.elementAt(i+10);
		if(bolRemoveStudent)
			vStudList = new Vector();
	if(bolPrintHeader){%>
	<tr>		
		<td class="thinborder" width="15%" height="20"><strong>Subject Code</strong></td>
		<td class="thinborder" width=""><strong>Subject Name</strong></td>
		<td class="thinborder" width="5%" align="center"><strong>Section</strong></td>
		<td class="thinborder" width="10%" align="center"><strong>Total Enrolled</strong></td>
		<td class="thinborder" width="20%"><strong>Dissolved By</strong></td>		
		<td class="thinborder" width="20%"><strong>Date & Time</strong></td>
	</tr>
	<%
	if(bolRemoveStudent)
		bolPrintHeader = false;
	}%>
		
	<tr>		
		<td class="thinborder" height="20"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		<td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+5)%></td>
		<td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+9)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>		
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>		
	</tr>
	
	<%if(vStudList.size() > 0){%>
	
	<tr>
		<td colspan="6" class="">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="" bgcolor="#FFFFFF">
				<tr>
					<td width="15%" class="thinborder" height="21"><strong>Student ID</strong></td>
					<td class="thinborder"><strong>Student Name</strong></td>
					<td width="10%" align="center" class="thinborder"><strong>Gender</strong></td>
					<td width="15%" class="thinborder"><strong>Course-Major</strong></td>					
					<td width="10%" class="thinborder" align="center"><strong>Year </strong></td>					
				</tr>
				
				
				<%
				for(int x = 0; x < vStudList.size(); x+=7){
				%>
				<tr>
					<td class="thinborder" height="20"><%=(String)vStudList.elementAt(x)%></td>
					<td class="thinborder"><%=(String)vStudList.elementAt(x+1)%></td>
					<td align="center" class="thinborder"><%=(String)vStudList.elementAt(x+2)%></td>
					<td class="thinborder"><%=(String)vStudList.elementAt(x+3)%><%=WI.getStrValue((String)vStudList.elementAt(x+5),"-","","")%></td>	
					<td align="center" class="thinborder"><%=WI.getStrValue((String)vStudList.elementAt(x+4))%></td>					
				</tr>				
				<%}%>
			</table>
		</td>
	</tr>
	
	<%}%>
	
	<%}%>
	
</table>

  

<%}%>
  
  
  
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="search_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
