<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.search_.value ='';
	document.form_.submit();
}
function PrintPage() {
	if(!confirm('Click OK to print report.'))
		return;
	
	var obj = document.getElementById('myADTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	obj = document.getElementById('myADTable2');
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	window.print();
}
</script>

<body bgcolor="#ffffff">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Program fix-Student Password Batch",
								"student_password_batch.jsp");

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
														"System Administration","USER MANAGEMENT",request.getRemoteAddr(),
														null);

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}


int iMaxDisp = 0; 
Vector vRetResult = new Vector();
String strSQLQuery = null;
java.sql.ResultSet rs = null;

%>


<form name="form_" action="./student_password_batch.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="25" colspan="2"><div align="center"><strong>:::: 
          STUDENT PASSWORD ACCESS PAGE ::::</strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td height="24">&nbsp;</td>
      <td>SY-Term</td>
      <td colspan="2">
	  <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes"> 
        - 
	  <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>	  </td>
    </tr>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td width="2%" height="24">&nbsp;</td>
      <td width="9%">College</td>
      <td colspan="2"> <select name="c_index" onChange="ReloadPage();" style="width:500px;">
          <option value="">N/A</option>
      <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Course</td>
      <td colspan="2"><select name="course_" style="width:500px;">
        <option value=""></option>
<%
if(strCollegeIndex.length() > 0)
	strTemp = " and c_index = "+strCollegeIndex;
else	
	strTemp = "";
//System.out.println(strTemp);
%>
        <%=dbOP.loadCombo("course_index","course_code, course_name", " from course_offered where is_valid = 1 and is_offered = 1"+strTemp, WI.fillTextValue("course_"),false)%>
      </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="54%">
	  <input type="submit" name="1" value="<<< Generate List >>>" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.search_.value='1';document.form_.submit();">	  </td>
      <td width="35%" align="right" style="font-size:9px;">
	  <a href="javascript:PrintPage();"> <img src="../../images/print.gif" border="0"></a>Print Page
	  </td>
    </tr>
  </table>
<%if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("search_").length() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr><td align="right" style="font-size:9px;">Date Time Printed: <%=WI.getTodaysDateTime()%></td></tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr bgcolor="#CCCCCC" align="center" style="font-weight:bold">
    <td class="thinborder" width="5%">Count </td>
  	<td class="thinborder" height="22" width="20%">Student ID </td>
  	<td class="thinborder" width="30%">Student Name </td>
  	<td class="thinborder" width="15%">Course - Yr </td>
  	<td class="thinborder" width="15%">College</td>
  	<td class="thinborder" width="15%">Password </td>
  	</tr>
<%
strSQLQuery = "select id_number, fname, mname, lname, user_id, password, course_offered.course_code, year_level, college.c_code from stud_curriculum_hist "+
				"join user_table on (user_table.user_index = stud_curriculum_hist.user_index) "+
				"join login_info on (login_info.user_index = user_table.user_index) "+
				"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
				"join college on (college.c_index = course_offered.c_index) "+
				" where stud_curriculum_hist.sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+" and stud_curriculum_hist.is_valid = 1 ";
				
if(strCollegeIndex.length() > 0) 
	strSQLQuery += " and college.c_index = "+strCollegeIndex;
if(WI.fillTextValue("course_").length() > 0) 
	strSQLQuery += " and course_offered.course_index  = "+WI.fillTextValue("course_");
				
strSQLQuery += " order by lname, fname";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {%>
	  <tr>
	    <td class="thinborder"><%=++iMaxDisp%>.</td>
		<td class="thinborder" height="22"><%=rs.getString(1)%></td>
		<td class="thinborder"><%=WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4)%></td>
		<td class="thinborder"><%=rs.getString(7)%><%=WI.getStrValue(rs.getString(8), " - ", "","")%></td>
		<td class="thinborder"><%=rs.getString(9)%></td>
		<td class="thinborder"><%=rs.getString(6)%></td>
	  </tr>
<%}
rs.close();%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td align="center">&nbsp;</td>
    </tr>
  </table>
<%}%>
<input type="hidden" name="search_" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
