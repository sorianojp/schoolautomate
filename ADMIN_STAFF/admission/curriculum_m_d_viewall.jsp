<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function PrintPage()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
		return true;
	return false;
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strCourseIndex 	= request.getParameter("ci");
	String strCourseName 	= request.getParameter("cname");
	String strMajorIndex 	= request.getParameter("mi");
	String strMajorName 	= request.getParameter("mname");
	if(strMajorName == null || strMajorName.trim().length() ==0) strMajorName = "None";
	String strCYFrom 		= request.getParameter("syf");
	String strCYTo 			= request.getParameter("syt");

	float fTotalUnit = 0;

	if(strCourseIndex == null || strCYFrom == null || strCYTo == null)
	{
		strErrMsg = "Can't process curriculum detail. couse, Curriculum Year from and to information missing.";
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=strErrMsg%></font></p>
		<%
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Courses Curriculum","curriculum_m_d_viewall.jsp");
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
														"Admission","Courses Curriculum",request.getRemoteAddr(),
														"curriculum_m_d_viewall.jsp");
iAccessLevel = 2;//Switch off security, i do not need security as this is a view page only.

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumMaintenance CM = new CurriculumMaintenance();
Vector[] vCurDetail = CM.getMasteralCurDetail(dbOP, strCourseIndex, strMajorIndex,strCYFrom, strCYTo);
dbOP.cleanUP();

if(vCurDetail == null)
{
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=CM.getErrMsg()%></font></p>
		<%
		return;
	}
%>
<form action="./curriculum_m_d_viewall_print.jsp" method="post" target="_blank" onSubmit="return PrintPage();">
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" ><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM - MASTERS &amp; DOCTORAL DEGREE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:history.back();" target="_self">
	  <img src="../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td height="25">&nbsp;</td>

      <td height="25"><input name="image" type="image" src="../../images/print.gif" width="58" height="26">
        <font size="1">click
        to print curriculum</font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2">Course: <strong><%=strCourseName%></strong></td>
      <td width="33%" valign="middle">CURRICULUM YEAR: <strong><%=strCYFrom%>
        - <%=strCYTo%></strong></td>
    </tr>
<%
if(strMajorName.compareTo("None") != 0){%>
	 <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="49%" valign="middle">Major: <strong><%=strMajorName%></strong></td>
      <td width="15%" valign="middle">&nbsp;</td>
      <td width="33%" valign="middle">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="34%" bgcolor="#FFFFFF"><strong>Course Requirement</strong></td>
      <td width="39%" >&nbsp;</td>
      <td ><div align="center"><strong>Units</strong></div></td>
      <td >&nbsp;</td>
    </tr>
    <tr>
<%
for(int i=0; i< vCurDetail[0].size(); ++i)
{
	fTotalUnit += Float.parseFloat((String)vCurDetail[0].elementAt(i+1));
%>
     <td height="25" >&nbsp;</td>
      <td ><%=(String)vCurDetail[0].elementAt(i++)%></td>
      <td >.................................................................</td>
      <td ><div align="center"><%=(String)vCurDetail[0].elementAt(i)%> units</div></td>
      <td >&nbsp;</td>
    </tr>
<%}%>

    <tr>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td width="10%" valign="top" align="center" ><hr size="1"><%=fTotalUnit%></td>
      <td width="14%" >&nbsp;</td>
    </tr>
  </table>
  <table width="100%" height="100" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
<%
//System.out.println(vCurDetail[0]);
//System.out.println(vCurDetail[1]);
String strTemp2 = null;
for(int i=0, j=0; i< vCurDetail[0].size(); ++i) //arrange according to requirement
{
	strTemp = (String)vCurDetail[0].elementAt(i++);

%>
<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="4"><strong><%=strTemp%></strong></td>
    </tr>
<%	for(;j<vCurDetail[1].size();++j){
	strTemp2 = (String)vCurDetail[1].elementAt(j);
	if(strTemp.compareTo(strTemp2) != 0) break;
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="23%"><%=(String)vCurDetail[1].elementAt(++j)%></td>
      <td width="47%"><%=(String)vCurDetail[1].elementAt(++j)%></td>
      <td width="18%"><%=(String)vCurDetail[1].elementAt(++j)%></td>
    </tr>
<%}
//}//if compare is matching.
}//outer loop%>
  </table>

  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td width="88%" height="25"> <font size="1">
        <input name="image2" type="image" src="../../images/print.gif" width="58" height="26">
        click to print curriculum</font></td>
    </tr>
    <tr>
      <td colspan="2"><div align="center"> </div></td>
    </tr>
    <tr>
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="ci" value="<%=request.getParameter("ci")%>">
<input type="hidden" name="cname" value="<%=request.getParameter("cname")%>">
<%
strTemp = request.getParameter("mi");
if(strTemp == null) strTemp = "";
%>
<input type="hidden" name="mi" value="<%=strTemp%>">
<input type="hidden" name="mname" value="<%=WI.fillTextValue("mname")%>">
 <input type="hidden" name="syf" value="<%=request.getParameter("syf")%>">
<input type="hidden" name="syt" value="<%=request.getParameter("syt")%>">
</form>

</body>
</html>
