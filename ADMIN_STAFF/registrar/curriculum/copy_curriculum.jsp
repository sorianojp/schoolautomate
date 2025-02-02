<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function ReloadCourseIndex()
{
	if(document.ccurriculum.sy_from.selectedIndex > -1)
		document.ccurriculum.sy_from[document.ccurriculum.sy_from.selectedIndex].value = "";
	if(document.ccurriculum.major_index.selectedIndex > -1)
		document.ccurriculum.major_index[document.ccurriculum.major_index.selectedIndex].value = "";

	document.ccurriculum.submit();
}
function ReloadPage()
{
	document.ccurriculum.submit();
}
function PageAction(strAction)
{
	document.ccurriculum.page_action.value=strAction;
}
</script>
<body bgcolor="#D2AE72">
<form action="./copy_curriculum.jsp" method="post" name="ccurriculum">
<%@ page language="java" import="utility.*,enrollment.SubjectSection, enrollment.CurriculumMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	int i = -1;
	int j=0;
	String strSYFrom 		= request.getParameter("sy_from");
	String strSYTo = null; // this is used in
	Vector vTemp = new Vector();

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Copy Curriculum","copy_curriculum.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"copy_curriculum.jsp");
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

SubjectSection SS = new SubjectSection();
CurriculumMaintenance CM = new CurriculumMaintenance();
if(WI.fillTextValue("page_action").length() > 0)
{
	if(CM.copyCurriculum(dbOP,request))
		strErrMsg = "Operation successful.";
	else
		strErrMsg = CM.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";
%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center"><font color="#FFFFFF"><strong>::
        COURSES CURRICULUM ::</strong></font></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="31%">Course</td>
      <td width="67%">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"> <select name="course_index" onChange="ReloadCourseIndex();">
          <option value="0">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", request.getParameter("course_index"), false)%>
        </select> </td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td>Major</td>
      <td>Curriculum Year</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
        <select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
if(WI.fillTextValue("course_index").length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+request.getParameter("course_index")+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select></td>
      <td> <select name="sy_from" onChange="ReloadPage();">
          <%
//get here school year
vTemp = SS.getSchYear(dbOP, request);
strTemp = request.getParameter("sy_from");//System.out.println(strTemp);
if(strTemp == null) strTemp = "";

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%></option>
          <%	}
	i = i+2;

}
if(vTemp.size() > 0)
	strSYTo = (String)vTemp.elementAt(j+1);
else
	strSYTo = "";

%>
        </select>
        to <b><%=strSYTo%></b>
<input type="hidden" name="sy_to" value="<%=strSYTo%>">
      </td>
    </tr>
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td>Operation :
        <select name="operation" onChange="ReloadPage();">
		<option value="0">Edit curriculum Year</option>
<%
if(WI.fillTextValue("operation").compareTo("1") ==0){%>
		<option value="1" selected>Copy Curriculum</option>
<%}else{%>
		<option value="1">Copy Curriculum</option>
<%}if(WI.fillTextValue("operation").compareTo("2") ==0){%>
		<option value="2" selected>Delete Curriculum</option>
<%}else{%>
		<option value="2">Delete Curriculum</option>
<%}%>
        </select>
&nbsp;&nbsp;&nbsp;
<%
if(WI.fillTextValue("operation").compareTo("2") == 0){//delete curriculum.%>
	<%if(iAccessLevel ==2){%>
		<font size="1">Click to delete curriculum </font><input type="image" src="../../../images/delete.gif" onClick='PageAction("2");'>
	<%}else{%>
	Not authorized to delete
	<%}
}//if delete is selected.%>	</td>
    </tr><tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("operation").compareTo("0") == 0){%>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td>Enter Curriculum Year:
        <input type="text" name="cy_from" size="5" maxlength="5" value="<%=WI.fillTextValue("cy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        to
        <input type="text" name="cy_to" size="5" maxlength="5" value="<%=WI.fillTextValue("cy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
	<tr>
      <td height="25" width="2%">&nbsp;</td>
      <td>
	  <%if(iAccessLevel > 1){%>
	  <input name="image" type="image" src="../../../images/edit.gif" onClick="PageAction(0);"> Click to change the curriculum year
	  <%}else{%>Not authorized to edit<%}%></td>
    </tr>
  </table>
 <%}else if(WI.fillTextValue("operation").compareTo("1") == 0){%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="31%">Course</td>
      <td width="67%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="2"> <select name="course_index_to" onChange="ReloadPage();">
          <option value="0">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc",
		  	request.getParameter("course_index_to"), false)%>
        </select> </td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td>Major</td>
      <td>Curriculum Year</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
        <select name="major_index_to" onChange="ReloadPage();">
          <option></option>
          <%
if(WI.fillTextValue("course_index_to").length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+WI.fillTextValue("course_index_to")+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index_to"), false)%>
          <%}%>
        </select></td>
      <td><input type="text" name="cy_from" size="5" maxlength="5" value="<%=WI.fillTextValue("cy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        to
        <input type="text" name="cy_to" size="5" maxlength="5" value="<%=WI.fillTextValue("cy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
      </td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td>&nbsp;
	  <%if(iAccessLevel > 1){%>
	  <input type="image" src="../../../images/copy_all.gif" onClick="PageAction(1);"> click to copy the curriclum year to the new curriculum year
	  <%}else{%>Not authorized to copy curriculum <%}%></td>
    </tr>

  </table>
<%}%>


<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td height="25">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
