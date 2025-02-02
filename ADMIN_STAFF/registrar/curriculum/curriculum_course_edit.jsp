<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript">
function EditRecord(strTargetIndex)
{
	document.ccourse.editRecord.value = 1;
	return;
}
function updateMajor()
{
	var course_code = document.ccourse.course_code.value;
	var course_name = document.ccourse.course_name.value;
	if(course_code.length == 0)
	{
		alert("please enter a course code to add major.");
		document.ccourse.course_code.focus();
		return;
	}
	if(course_name.length ==0)
	{
		alert(" please ente course name to add mojor under this course.");
		document.ccourse.course_name.focus();
		return;
	}
	var cc_index = document.ccourse.cc_index[document.ccourse.cc_index.selectedIndex].value;
	var c_index = document.ccourse.c_index[document.ccourse.c_index.selectedIndex].value;
	location= "./curriculum_coursemajor.jsp?course_code="+escape(course_code)+"&course_name="+escape(course_name)+"&cc_index="+
				escape(cc_index)+"&c_index="+escape(c_index)+"&caller_info_index="+document.ccourse.info_index.value;
}
function ReloadPage()
{
	document.ccourse.reloadPage.value="1";
	document.ccourse.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumCourse,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	WebInterface WI = new WebInterface(request);
	boolean bolIsReload = false; //if page is reloaded, do not use the edit information.
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Edit course","curriculum_course_edit.jsp");
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
														"curriculum_course_edit.jsp");
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

Vector vRetResult = new Vector();

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumCourse CC = new CurriculumCourse();
strTemp = request.getParameter("editRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(CC.edit(dbOP,request))
	{
		strErrMsg = "Course edited successfully.";
	}
	else
	{
		strErrMsg = CC.getErrMsg();
	}
}
else
{
	vRetResult = CC.view(dbOP,request);
	if(vRetResult == null || vRetResult.size() == 0)
		strErrMsg = CC.getErrMsg();
}
if(request.getParameter("reloadPage") != null && request.getParameter("reloadPage").compareTo("1") ==0)
	bolIsReload = true;
%>

<form name="ccourse" action="./curriculum_course_edit.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          COURSES ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="44%" height="25"><a href="curriculum_course.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%
if(strErrMsg != null)
{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%
dbOP.cleanUP();
return;
}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
<%
if(bolIsReload)
	strTemp = WI.fillTextValue("not_offered");
else strTemp = (String)vRetResult.elementAt(8);

if(strTemp.compareTo("0") == 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="not_offered" value="0"<%=strTemp%>>
        Not Offered</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Enter course code </td>
      <td width="51%">Course name</td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td height="25"> 
<%
if(bolIsReload)
	strTemp = WI.fillTextValue("course_code");
else strTemp = (String)vRetResult.elementAt(2);
%> <input name="course_code" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td> <%
if(bolIsReload)
	strTemp = WI.fillTextValue("course_name");
else strTemp = (String)vRetResult.elementAt(3);
%> <input name="course_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Course classification</td>
      <td>College offering the course</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> <select name="cc_index">
          <%
if(bolIsReload)
	strTemp = WI.fillTextValue("cc_index");
else strTemp = (String)vRetResult.elementAt(0);
%>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc",strTemp, false)%> </select> </td>
      <td> <%
if(bolIsReload)
	strTemp = WI.fillTextValue("c_index");
else strTemp = (String)vRetResult.elementAt(1);
%> <select name="c_index" onChange="ReloadPage();">
          <%=dbOP.loadCombo("c_index","c_name"," from COLLEGE where IS_DEL=0 order by c_name asc",strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Tuition type</td>
      <td>Department</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> <select name="tution_type">
          <option value="0">Annual</option>
<%
 if(bolIsReload)
	strTemp = WI.fillTextValue("tution_type");
 else 
 	strTemp = (String)vRetResult.elementAt(4);

 if(strTemp == null) strTemp = "";

if(strTemp.equals("1")) 
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>

          <option value="1" <%=strErrMsg%>>Semestral</option>
<%
if(strTemp.equals("2")) 
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>Trimestral</option>
        </select></td>
      <td> <%
if(bolIsReload)
	strTemp = WI.fillTextValue("c_index");
else strTemp = (String)vRetResult.elementAt(1);

if(bolIsReload)
	strTemp2 = WI.fillTextValue("d_index");
else
	strTemp2 = (String)vRetResult.elementAt(5);
%> <select name="d_index">
          <%
 if(strTemp != null && strTemp.trim().length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp2, false)%> 
          <%}
	dbOP.cleanUP();%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Curriculum format</td>
      <td>ID Code intial</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> <%
if(bolIsReload)
	strTemp = WI.fillTextValue("degree_type");
else strTemp = (String)vRetResult.elementAt(6);
%> <select name="degree_type">
          <option value="0">Undergraduate</option>
          <%
	 if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Graduate</option>
          <%}else{%>
          <option value="1">Graduate</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>College of Medicine</option>
          <%}else{%>
          <option value="2">College of Medicine</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Course with Preparatory</option>
          <%}else{%>
          <option value="3">Course with Preparatory</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>Caregiver</option>
          <%}else{%>
          <option value="4">Caregiver</option>
          <%}%>
        </select></td>
      <%
if(bolIsReload)
	strTemp = WI.fillTextValue("id_initial");
else strTemp = WI.getStrValue(vRetResult.elementAt(7));
%>
      <td><input type="text" name="id_initial" value="<%=strTemp%>" size="5" maxlength="5" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td>&nbsp; </td>
      <td> <%if(iAccessLevel > 1){%> <input name="image" type="image" onClick="EditRecord();" src="../../../images/edit.gif" border="0"> 
        <font size="1">click to save changes</font> <%}else{%>
        Not authorized to edit. <%}%> </td>
      <td> <%if(iAccessLevel > 1){%> <a href="javascript:updateMajor();" target="_self"><img src="../../../images/update.gif" border="0"></a> 
        <font size="1">click to update list of Major under this course</font> 
        <%}%> </td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</div></td>
    </tr>
  </table>

<table width="100%" bgcolor="#FFFFFF" border=0>
 <tr> <td></td>
    </tr>
    <tr>
      <td>
          <hr size="1">
        </td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>

    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
<%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>

<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
