<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
function ReloadPage()
{
	document.assessment_sch.action = "./assessment_sched_batch.jsp";
	document.assessment_sch.submit();
}
function CallPrint()
{
	document.assessment_sch.action = "./assessment_sched_batch_print.jsp";
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=assessment_sch.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
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
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT-assessment batch sched","assessment_sched_batch.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"assessment_sched_batch.jsp");
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

if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
%>

<form name="assessment_sch" action="" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          PRINT SCHEDULE ASSESSMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;</td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Print by </td>
      <td width="15%" height="25"><select name="print_by" onChange="ReloadPage();">
          <option value="0">Student</option>
          <%
strTemp = WI.fillTextValue("print_by");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Course</option>
          <%}else{%>
          <option value="1">Course</option>
          <%}%>
        </select></td>
      <td width="12%">Exam Period </td>
      <td width="23%"><strong>
        <select name="pmt_schedule">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        </select>
        </strong></td>
      <td width="32%" colspan="2">&nbsp; </td>
    </tr>
    <%
strTemp = WI.fillTextValue("print_by");
if(strTemp.compareTo("1") != 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Enter Student ID </td>
      <td height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>
      <td height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td height="25"  colspan="3">School Year : <strong><%=(String)request.getSession(false).getAttribute("cur_sch_yr_from")%> - <%=(String)request.getSession(false).getAttribute("cur_sch_yr_to")%> (<%=astrConvertTerm[Integer.parseInt((String)request.getSession(false).getAttribute("cur_sem"))]%>)</strong></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Select Course </td>
      <td height="25" colspan="5"><select name="course_index" onChange="ReloadPage();">
          <option value="0">Select Any</option>
          <%
//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Major</td>
      <td height="25" colspan="5"> <select name="major_index">
          <%
strTemp = request.getParameter("course_index");
if(strTemp != null && strTemp.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="16%" height="25">Select Year level </td>
      <td height="25" colspan="2"><select name="year_level">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("year_level");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0)
{%>
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
        </select></td>
      <td height="25" colspan="3">School Year(Term) : <strong><%=(String)request.getSession(false).getAttribute("cur_sch_yr_from")%>
        - <%=(String)request.getSession(false).getAttribute("cur_sch_yr_to")%>
		(<%=astrConvertTerm[Integer.parseInt((String)request.getSession(false).getAttribute("cur_sem"))]%>)</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="6" height="25">Print students whose lastname starts with
        <select name="lname_from" onChange="ReloadPage()">
          <%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        to
        <select name="lname_to">
          <option value="0"></option>
          <%
 strTemp = WI.fillTextValue("lname_to");

 for(int i=++j; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Number of students to be printed per page : 
      </td>
      <td colspan="2">
	  <select name="stud_per_pg">
		<option value="4">4</option>      
<%
strTemp = WI.fillTextValue("stud_per_pg");
if(strTemp.compareTo("6") == 0) {%>
		<option value="6" selected>6</option>		
<%}else{%>
		<option value="6">6</option>
<%}if(strTemp.compareTo("8") == 0) {%>
		<option value="8" selected>8</option>		
<%}else{%>
		<option value="8">8</option>
<%}if(strTemp.compareTo("10") == 0) {%>
		<option value="10" selected>10</option>		
<%}else{%>
		<option value="10">10</option>
<%}%>				
	  </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%}//if print_by is not student
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> <input type="image" src="../../../images/form_proceed.gif" onClick="CallPrint()">
        <font size="1">click to start printing</font></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7">&nbsp;</td>
    </tr>
  </table>
      <input type="hidden" name="sy_from" value="<%=(String)request.getSession(false).getAttribute("cur_sch_yr_from")%>">
      <input type="hidden" name="sy_to" value="<%=(String)request.getSession(false).getAttribute("cur_sch_yr_to")%>">
	</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
