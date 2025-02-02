<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>

</head>

<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.CurriculumCourse,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses","curriculum_course_print.jsp");
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
														"curriculum_course_print.jsp");
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
Vector vRetResult = new Vector();
vRetResult = CC.viewAll(dbOP,request,true);//print is true.

Vector vNotOffered = new Vector();
String strSQLQuery = "select course_index from course_offered where is_offered = 0";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next())
	vNotOffered.addElement(rs.getString(1));
rs.close();

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="2" ><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        <br>
        COURSES LISTING
        <br>
      </div></td>
  </tr>
  <tr>
    <td height="19" colspan="2"><hr size="1"></td>
  </tr>
  <tr>
    <td width="51%" height="25">TOTAL COURSES :<b> <%=vRetResult.size()/8%></b></td>
    <td width="49%" height="25">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td width="11%" height="25" class="thinborder"><div align="center"><strong><font size="1">COURSE 
        CODE </font></strong></div></td>
    <td width="22%" class="thinborder"><div align="center"><strong><font size="1">COURSE NAME </font></strong></div></td>
    <td width="17%" class="thinborder"><div align="center"><strong><font size="1">CLASSIFICATION</font></strong></div></td>
    <td width="20%" class="thinborder"><div align="center"><strong><font size="1">MAJOR</font></strong></div></td>
    <td width="20%" class="thinborder"><div align="center"><strong><font size="1">COLLEGE OFFERING</font></strong></div></td>
    <td width="8%" class="thinborder"><div align="center"><strong><font size="1">CUR FORMAT</font></strong></div></td>
    <td width="8%" class="thinborder"><div align="center"><strong><font size="1">ID CODE</font></strong></div></td>
  </tr>
  <%

for(int i = 0 ; i< vRetResult.size(); i +=8) {
	if(vNotOffered.indexOf(vRetResult.elementAt(i)) > -1)
		strTemp = " style='font-weight:bold'";
	else	
		strTemp = "";
%>
  <tr<%=strTemp%>> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
  </tr>
  <%}%>
</table>
<%if(WI.fillTextValue("not_offered").length() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
  	<td style="font-weight:bold; font-size:9px;">Note: Rows in BOLD are the courses not offered.</td>
  </tr>
</table>
<%}%>
</body>
</html>
