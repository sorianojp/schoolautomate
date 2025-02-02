<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

-->
</style>

</head>

<body >
<%@ page language="java" import="utility.*,enrollment.CurriculumCClassification,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

	boolean bolIsSuccess = false;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Course Classfication","curriculum_course_classification_print.jsp");
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
														"curriculum_course_classification_print.jsp");
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

CurriculumCClassification CC = new CurriculumCClassification();

//get all levels created.
Vector vRetResult = new Vector();
vRetResult = CC.viewall(dbOP);

if(vRetResult ==null)
{dbOP.cleanUP();%>
	<p align="center"> <font  size="3">
	<%=CC.getErrMsg()%></font></p>
	<%
	return;
}

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="2" ><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        <br>
        COURSE PROGRAMS LISTING <br>
        <br>
      </div></td>
  </tr>
  <tr>
    <td height="25" colspan="2"><hr size="1"></td>
  </tr>
  <tr>
    <td width="51%" height="25">Total Course Programs:<b> <%=vRetResult.size()/4%></b></td>
    <td width="49%" height="25">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>
<table width="90%" border="1" align="center" cellpadding="0" cellspacing="0" >
  <tr> 
    <td height="25"> &nbsp;<strong>ORDER NO.</strong></td>
    <td height="25"><div align="center"><strong>COURSE PROGRAM CODE</strong></div></td>
    <td><div align="center"><strong>COURSE PROGRAM NAME</strong></div></td>
  </tr>
  <%
for(int i = 0 ; i< vRetResult.size(); i +=4)
{%>
  <tr>
    <td height="25">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"", "]","&nbsp;")%></td>
    <td>&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
    <td>&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
  </tr>
  <%}//end of loop %>
</table>


<%
dbOP.cleanUP();
%>

<script language="javascript">
window.print();
window.setInterval("javascript:window.close();",0);
</script>

</body>
</html>
