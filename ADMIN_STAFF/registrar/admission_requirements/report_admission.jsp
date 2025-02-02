<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.course_requirement.submit();
}
function ViewRequirementDetail(strStudID) {
	var pgLoc = "./stud_admission_req.jsp?read_only=1&sy_from="+document.course_requirement.sy_from.value+
				"&sy_to="+document.course_requirement.sy_to.value+"&semester="+
				document.course_requirement.semester[document.course_requirement.semester.selectedIndex].value+
				"&stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CourseRequirement,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit=WI.fillTextValue("prepareToEdit");
	if(strPrepareToEdit.length() == 0 ) strPrepareToEdit="0";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar-admission requirement","report_admission.jsp");
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
														"Registrar Management","ADMISSION REQUIREMENTS",request.getRemoteAddr(),
														"report_admission.jsp");
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

CourseRequirement cRequirement = new CourseRequirement();
Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = cRequirement.listOfStudWithPendingReq(dbOP,request);
	if(vRetResult == null) {
		strErrMsg = cRequirement.getErrMsg();	
	}
}


%>


<form name="course_requirement" action="./report_admission.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          ADMISSION REQUIREMENT REPORT ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="16%">School year </td>
      <td> 
<%
strTemp = request.getParameter("sy_from");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("course_requirement","sy_from","sy_to")'>
        to 
        <%
strTemp = request.getParameter("sy_to");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student ID</td>
      <td><input type="text" name="stud_id" size="20" maxlength="32" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(enter ID if report is for a specific student)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td> <% strTemp = WI.fillTextValue("c_index"); %> <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name"," from College where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course </td>
      <td> <%strTemp = null;
if(WI.fillTextValue("c_index").length() > 0){
		strTemp = WI.fillTextValue("course_index");
	%> <select name="course_index" onChange="ReloadPage();">
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+
		  WI.fillTextValue("c_index") + "  order by course_name asc", strTemp, false)%> </select> <%}//if c_index is selected
%> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major </td>
      <td><select name="major_index">
          <option ></option>
          <%
if(strTemp != null && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, WI.fillTextValue("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href='javascript:ReloadPage();'><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong>Sorting Conditions : </strong></td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="36%">
	  <select name="sort_by1" id="sort_by1">
	  	  <option value="0"> Sort By</option>
	  <%if (WI.fillTextValue("sort_by1").compareTo("1") == 0){%>
          <option value="1" selected>ID </option>
	  <%}else{%>
          <option value="1">ID </option>	  
	  <%}if (WI.fillTextValue("sort_by1").compareTo("2") == 0){%>
          <option value="2" selected>First Name </option>
	  <%}else{%>
          <option value="2">First Name </option>	  
	  <%}if (WI.fillTextValue("sort_by1").compareTo("3") == 0){%>
          <option value="3" selected>Last Name </option>
	  <%}else{%>
          <option value="3">Last Name </option>	  
	  <%}if (WI.fillTextValue("sort_by1").compareTo("4") == 0){%>
          <option value="4" selected>Course </option>
	  <%}else{%>
          <option value="4">Course </option>	  
	  <%}if (WI.fillTextValue("sort_by1").compareTo("5") == 0){%>
          <option value="5" selected>Major </option>
	  <%}else{%>
          <option value="5">Major </option>	  
	  <%}%>
        </select>
		<select name="sort_by1_cond">
          <option value=" asc">Ascending</option>
          <% if (WI.fillTextValue("sort_by1_cond").startsWith("d")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="58%">
	  <select name="sort_by2" id="sort_by2">
	  	  <option value="0"> Sort By</option>
	  <%if (WI.fillTextValue("sort_by2").compareTo("1") == 0){%>
          <option value="1" selected>ID </option>
	  <%}else{%>
          <option value="1">ID </option>	  
	  <%}if (WI.fillTextValue("sort_by2").compareTo("2") == 0){%>
          <option value="2" selected>First Name </option>
	  <%}else{%>
          <option value="2">First Name </option>	  
	  <%}if (WI.fillTextValue("sort_by2").compareTo("3") == 0){%>
          <option value="3" selected>Last Name </option>
	  <%}else{%>
          <option value="3">Last Name </option>	  
	  <%}if (WI.fillTextValue("sort_by2").compareTo("4") == 0){%>
          <option value="4" selected>Course </option>
	  <%}else{%>
          <option value="4">Course </option>	  
	  <%}if (WI.fillTextValue("sort_by2").compareTo("5") == 0){%>
          <option value="5" selected>Major </option>
	  <%}else{%>
          <option value="5">Major </option>	  
	  <%}%>
        </select>

        <select name="sort_by2_cond" id="sort_by2_cond">
          <option value=" asc">Ascending</option>
          <% if (WI.fillTextValue("sort_by1_cond").startsWith("d")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center"><strong>LIST OF STUDENTS 
               WITH LACKING ADMISSION REQUIREMENTS</strong></div></td>
    </tr>
	  <tr> 
		<td width="17%"><div align="center"><strong><font size="1">ID NUMBER</font></strong></div></td>
		<td width="30%" height="25"><div align="center"><font size="1"><strong>NAME 
			OF STUDENT</strong></font></div></td>
		<td width="46%" align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
		<td width="7%" align="center"><font size="1"><strong>VIEW</strong></font></td>
	  </tr>
<%
for(int i = 0 ; i< vRetResult.size() ; i +=4){%>
	  <tr> 
		
      <td>&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
		
      <td height="25">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
		
      <td>&nbsp;<%=(String)vRetResult.elementAt(i + 2) + WI.getStrValue((String)vRetResult.elementAt(i+3)," :: ","","")%>
		</td>
		<td> <a href='javascript:ViewRequirementDetail("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/view.gif" border="0"></a> 
		</td>
	  </tr>
<%}%>
  </table>
<%}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
