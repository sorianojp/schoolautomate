<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript">
function AddRecord()
{
	document.ccourse.addRecord.value = 1;
	document.ccourse.deleteRecord.value = "";
}


function EditRecord(strTargetIndex)
{
	location="./curriculum_course_edit.jsp?info_index="+strTargetIndex;
	return;
}

function DeleteRecord(strTargetIndex)
{
	document.ccourse.addRecord.value = "";
	document.ccourse.deleteRecord.value = 1;
	document.ccourse.info_index.value = strTargetIndex;

	document.ccourse.submit();
}

function goToNextSearchPage()
{
	document.ccourse.addRecord.value = "";
	document.ccourse.deleteRecord.value = "";
	document.ccourse.info_index.value = 0;

	document.ccourse.submit();
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
				escape(cc_index)+"&c_index="+escape(c_index);
}
function ReloadPage()
{
	document.ccourse.addRecord.value = "";
	document.ccourse.deleteRecord.value = "";
	document.ccourse.submit();
}
function PrintPg() {
	var strURL = "./curriculum_course_print.jsp";
	if(document.ccourse.not_offered.checked)
		strURL = strURL + "?not_offered=1";
		
	var win=window.open(strURL,"PrintWindow",'width=900,height=700,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>

<body bgcolor="#D2AE72" onLoad="document.ccourse.course_code.focus();">
<%@ page language="java" import="utility.*,enrollment.CurriculumCourse,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses","curriculum_course.jsp");
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
														"curriculum_course.jsp");
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

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumCourse CC = new CurriculumCourse();
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(CC.add(dbOP,request))
	{
		strErrMsg = "Course added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=CC.getErrMsg()%></font></p>
		<%
		return;
	}
}
strTemp = request.getParameter("deleteRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//delete here and set strErrMsg();
	strTemp = request.getParameter("info_index");
	if(strTemp == null || strTemp.length() == 0)
	{
		strErrMsg = "Error in deleting Schedule. Please try again.";
	}
	else
	{
		if(!CC.delete(dbOP,strTemp,(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = CC.getErrMsg();
		else
			strErrMsg = "Course deleted successfully.";
	}
}

//collect all the schedule information.
int iSearchResult = 0;
Vector vRetResult = new Vector();
vRetResult = CC.viewAll(dbOP,request);
iSearchResult = CC.iSearchResult;

%>

<form name="ccourse" action="./curriculum_course.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          COURSES ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
    <%
if(strErrMsg != null)
{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5"><font size="3"><%=strErrMsg%></td>
    </tr>
    <%}%>
    <tr> 
      <td width="2%" height="25" rowspan="3">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom">Course Code </td>
      <td width="62%" colspan="2" valign="bottom">Course name </td>
    </tr>
    <tr> 
      <td colspan="3" height="13"> <input name="course_code" type="text" size="16" value="<%=WI.fillTextValue("course_code")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="62%" colspan="2"> <input name="course_name" type="text" size="32" value="<%=WI.fillTextValue("course_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25" colspan="3" valign="bottom">Course Programs</td>
      <td width="62%" colspan="2" valign="bottom">College offering the course</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25"> <select name="cc_index">
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", request.getParameter("cc_index"), false)%> 
        </select> </td>
      <td colspan="2"> <select name="c_index" onChange="ReloadPage();">
          <option value="0">Select a College</option>
          <%=dbOP.loadCombo("c_index","c_name"," from COLLEGE where IS_DEL=0 order by c_name asc", request.getParameter("c_index"), false)%> 
        </select> </td>
    </tr>
    <tr> 
      <td height="25" rowspan="2">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom">Tuition type</td>
      <td colspan="2" valign="bottom">Department</td>
    </tr>
    <tr> 
      <td colspan="3" height="25"><select name="tution_type">
          <option value="0">Annual</option>
<%
 strTemp = request.getParameter("tution_type");
 if(strTemp == null) 
 	strTemp = "";
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
      <td colspan="2"> <select name="d_index">
          <option value="">N/A</option>
          <%
 strTemp = request.getParameter("c_index");
 if(strTemp != null && strTemp.trim().length() > 0 && strTemp.compareTo("0") != 0){%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",request.getParameter("d_index"), false)%> 
          <%}
dbOP.cleanUP();%>
        </select></td>
    </tr>
    <tr> 
      <td colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3">Curriculum format</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3"><select name="degree_type">
          <option value="0">Undergraduate</option>
          <%
	 strTemp = WI.fillTextValue("degree_type");
	 if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Graduate</option>
          <%}else{%>
          <option value="1">Graduate</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Medicine</option>
          <%}else{%>
          <option value="2">Medicine</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>With Preparatory</option>
          <%}else{%>
          <option value="3">With Preparatory</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>Non-semestral</option>
          <%}else{%>
          <option value="4">Non-semestral</option>
          <%}%>
        </select></td>
      <td colspan="2"><input type="hidden" name="id_initial" value="-"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="18" colspan="3">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3"><input name="image" type="image" onClick="AddRecord();" src="../../../images/add.gif" border="0"> 
        <font size="1">click to add entry</font></td>
      <td colspan="2"> <a href="javascript:updateMajor();" target="_self"><img src="../../../images/update.gif" border="0"></a> 
        <font size="1">click to update list of Major under this course</font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td colspan="3">
<%
strTemp = WI.fillTextValue("not_offered");
if(strTemp.length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="not_offered" value="1"<%=strTemp%>>
        Include Courses not offered</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="33">&nbsp;</td>
      <td colspan="3">Show by(ascending) 
        <select name="order_by" style="font-size:10px">
          <option value="COURSE_CODE">Course code</option>
          <%
strTemp = WI.fillTextValue("order_by");
if(strTemp.compareTo("COURSE_NAME") == 0) 
	strTemp = "selected";
else	
	strTemp = "";
%>
          <option value="COURSE_NAME" <%=strTemp%>>Course 
          name</option>
        </select></td>
      <td colspan="2">To filter enter course code starts with 
        <input type="text" name="filter_course" value="<%=WI.fillTextValue("filter_course")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        and click REFRESH<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
      </td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="6"><div align="right"><font size="3"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>&nbsp;<font size="1">click 
          to print list </font></font></div></td>
    </tr>
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6"><div align="center">LIST OF EXISTING COURSES</div></td>
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
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" bgcolor="#FFFFFF">
    <tr>
      <td width="66%" ><b>
        Total courses created: <%=iSearchResult%> - Showing(<%=CC.strDispRange%>)</b></td>
      <td width="34%">
	  <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CC.defSearchSize;
		if(iSearchResult % CC.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
		<div align="right">Jump
          To page:
          <select name="jumpto" onChange="goToNextSearchPage();">

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

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFDF" align="center" style="font-weight:bold">
      <td width="11%" height="25" class="thinborder"><font size="1">COURSE CODE </font></td>
      <td width="22%" class="thinborder"><font size="1">COURSE NAME </font></td>
      <td width="17%" class="thinborder"><font size="1">CLASSIFICATION</font></td>
      <td width="20%" class="thinborder"><font size="1">MAJOR</font></td>
      <td width="20%" class="thinborder"><font size="1">COLLEGE OFFERING</font></td>
      <td width="20%" class="thinborder">Dept Offering </td>
      <td width="8%" class="thinborder"><font size="1">CUR FORMAT</font></td>
      <td width="7%" align="center" class="thinborder"><font size="1">EDIT</font></td>
      <td width="7%" align="center" class="thinborder"><font size="1">DELETE</font></td>
    </tr>
<%
String strBGColor = null;
for(int i = 0 ; i< vRetResult.size(); ++i){
if( ((String)vRetResult.elementAt(i + 8)).compareTo("1") == 0) 
	strBGColor = "";
else	
	strBGColor =" bgcolor=#EEEEEE" ;
%>
    <tr<%=strBGColor%>>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td height="25" align="center" class="thinborder">
        <%if(iAccessLevel > 1){%>
        <a href='javascript:EditRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/edit.gif" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%>      </td>
      <td align="center" class="thinborder">
        <%if(iAccessLevel ==2){%>
        <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%>      </td>
    </tr>
    <%
	i = i+9;
}%>
  </table>
 <%}//end of showing if there is course created.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="8"><div align="center"><font size="3"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>&nbsp;<font size="1">click 
          to print list </font></font></div></td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
 <input type="hidden" name="addRecord" value="0">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="info_index" value="0">
<input type="hidden" name="editRecord" value="0">
</form>
</body>
</html>
