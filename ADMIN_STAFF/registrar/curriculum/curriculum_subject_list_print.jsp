<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>

</head>

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.CurriculumSM,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = ""; String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Subjects Maintenance","curriculum_subject.jsp");
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
														"curriculum_subject.jsp");
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

CurriculumSM SM = new CurriculumSM();
int iSearchResult = 0;
//get all levels created.
Vector vRetResult = null;
if(WI.fillTextValue("print_pg").compareTo("1") ==0)
	vRetResult = SM.viewAll(dbOP,request);//called from subject maintainance page.
else//called from search subject page.
{
	//search here.
}
iSearchResult = SM.iSearchResult;
//dbOP.cleanUP();

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=SM.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}
boolean bolIncDesc = WI.fillTextValue("inc_").equals("1");
Vector vCourseDescription = new Vector();
if(bolIncDesc){
	strTemp = "select CM_SYL_MAIN.sub_index, course_desc from CM_SYL_MAIN join subject on (subject.sub_index = CM_SYL_MAIN.sub_index) order by sub_code";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vCourseDescription.addElement(new Integer(rs.getInt(1)));
		vCourseDescription.addElement(rs.getString(2));
	}
	rs.close();
}

Integer objInt = null; int iIndexOf = 0;
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="2" ><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        <br>
        SUBJECT LISTING <br>
        <br>
      </div></td>
  </tr>
  <tr>
    <td height="19" colspan="2"><hr size="1"></td>
  </tr>
  <tr>
    <td width="51%" height="25">Total Subjects :<b> <%=iSearchResult%></b></td>
    <td width="49%" height="25">Date &amp; Time Printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="15%" height="25" class="thinborder"><div align="center"><strong>Subject Code  </strong></div></td>
    <td width="37%" class="thinborder"><div align="center"><strong>Subject Title </strong></div></td>
<%if(bolIncDesc){%>
    <td width="48%" class="thinborder"><div align="center"><strong>Course Description  </strong></div></td>
<%}else{%>
    <td width="15%" class="thinborder"><div align="center"><strong>Subject Category </strong></div></td>
    <td width="15%" align="center" class="thinborder"><strong>Subject Group </strong></td>
    <td width="9%" align="center" class="thinborder"><strong>Min Reqd Student </strong></td>
    <td width="9%" class="thinborder"><div align="center"><strong>Max. Student Per Class</strong></div></td>
<%}%>
  </tr>
  <%
for(int i = 0 ; i< vRetResult.size(); ++i) {
objInt = new Integer((String)vRetResult.elementAt(i));%>
  <tr>
    <td class="thinborder" height="20"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
<%if(bolIncDesc){
iIndexOf = vCourseDescription.indexOf(objInt);
if(iIndexOf == -1)
	strTemp = "&nbsp;";
else {	
	vCourseDescription.remove(iIndexOf);
	strTemp = (String)vCourseDescription.remove(iIndexOf);
}%>
    <td class="thinborder"><%=strTemp%></td>
<%}else{%>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
    <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
<%}%>
  </tr>
  <%
i = i+8;
}//end of loop %>
</table>

</body>
</html>
<%
dbOP.cleanUP();
%>