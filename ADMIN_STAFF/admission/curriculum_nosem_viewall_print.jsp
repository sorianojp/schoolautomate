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

-->
</style>

</head>

<body >
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();

	String strCourseIndex 	= request.getParameter("course_index");
	String strCourseName 	= request.getParameter("cname");
	String strSYFrom 		= request.getParameter("cy_from");
	String strSYTo 			= request.getParameter("cy_to");
	String strCollegeName	= null;
	float fLecHrs = 0; float fLabHrs=0;

	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Courses Curriculum","curriculum_nosem_viewall.jsp");
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
														"curriculum_nosem_viewall.jsp");
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
if(strCourseIndex == null || strSYFrom == null || strSYTo == null)
{
	strErrMsg = "Can't process curriculum detail. couse, SY From , SY To information missing.";
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=strErrMsg%></font></p>
	<%
	return;
}
vRetResult = CM.operateOnCurWithNoSem(dbOP, request,3);
strCollegeName = CM.getCollegeName(dbOP,strCourseIndex);

//dbOP.cleanUP();

if(vRetResult == null || vRetResult.size() ==0)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CM.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
        return;
}
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="100%" height="25" colspan="4" ><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=strCollegeName%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        <br>
        <strong><%=strCourseName%></strong> <br>
        Curriculum Year <strong><%=strSYFrom%> - <%=strSYTo%></strong><br>
      </div></td>
  </tr>
  <tr>
    <td height="25" colspan="4"><hr size="1"></td>
  </tr>
</table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <%
if(vRetResult != null && vRetResult.size() > 0){%>
    <tr>
      <td width="2%" rowspan="2">&nbsp;</td>
      <td  height="19" rowspan="2"><div align="left"><font size="1"><strong>SUBJECT
          CODE</strong></font></div></td>
      <td rowspan="2"><div align="left"><font size="1"><strong>SUBJECT TITLE </strong></strong></font></div></td>
      <td colspan="2"><div align="center"><font size="1"><strong>HOURS</strong></font></div></td>
      <td rowspan="2"><div align="center"><font size="1"><strong>TOTAL</strong></font></div></td>
    </tr>
    <tr>
      <td width="6%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
    </tr>
<%
String strCurIndex = null;
float fLecHrsTemp = 0;
float fLabHrsTemp = 0;
int i=0;

Vector vCurSubInfo = (Vector)vRetResult.remove(0);
for(i = 0; i< vRetResult.size();){
if( ((String)vRetResult.elementAt(i+5)).compareTo("1") ==0)// optional
	break;
if(vCurSubInfo.size() > 0)
	strCurIndex = (String)vRetResult.elementAt(i);
fLecHrsTemp = Float.parseFloat((String)vRetResult.elementAt(i+3));
fLabHrsTemp = Float.parseFloat((String)vRetResult.elementAt(i+4));

fLecHrs += fLecHrsTemp;
fLabHrs += fLabHrsTemp;
%>

    <tr>
      <td>&nbsp;</td>
      <td width="27%"  height="19"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="38%"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+3))%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+4))%></td>
      <td width="20%" align="center"><%=(fLecHrsTemp+fLabHrsTemp)%></td>
    </tr>
<%
i = i+6;

	while(vCurSubInfo.size() > 0){
	if( ((String)vCurSubInfo.elementAt(0)).compareTo(strCurIndex) !=0)
		break;

	fLecHrsTemp = Float.parseFloat((String)vCurSubInfo.elementAt(3));
	fLabHrsTemp = Float.parseFloat((String)vCurSubInfo.elementAt(4));

	%>
		 <tr>
		  <td>&nbsp;</td>
		  <td width="27%"  height="19"></td>
		  <td width="38%"> &nbsp;&nbsp;* <%=(String)vCurSubInfo.elementAt(2)%></td>
		  <td align="center">(<%=WI.getStrValue(vCurSubInfo.elementAt(3))%>)</td>
		  <td align="center">(<%=WI.getStrValue(vCurSubInfo.elementAt(4))%>)</td>
		  <td width="20%" align="center">(<%=(fLecHrsTemp+fLabHrsTemp)%>)</td>
		</tr>
	<%
	vCurSubInfo.removeElementAt(0);	vCurSubInfo.removeElementAt(0);
	vCurSubInfo.removeElementAt(0);	vCurSubInfo.removeElementAt(0);
	vCurSubInfo.removeElementAt(0);
	}
}%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" align="center"><em><strong>Total hours : <%=(fLecHrs+fLabHrs)%>
        ,Lecture hours = <%=fLecHrs%>, Lab hours=<%=fLabHrs%></strong></em></td>
    </tr>
    <tr>
      <td height="22" colspan="6">&nbsp;</td>
    </tr>
<%
if(i<vRetResult.size()){//optional%>
	 <tr>
      <td height="22" colspan="6" align="center"><strong>OPTIONAL</strong></td>
    </tr>
<%
for(;i<vRetResult.size();++i){
fLecHrsTemp = Float.parseFloat((String)vRetResult.elementAt(i+3));
fLabHrsTemp = Float.parseFloat((String)vRetResult.elementAt(i+4));
%>

        <tr>
      <td>&nbsp;</td>
      <td width="27%"  height="19"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="38%"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+3))%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+4))%></td>
      <td width="20%" align="center"><%=(fLecHrsTemp+fLabHrsTemp)%></td>
    </tr>
<%
	i = i+5;
	}
}%>

  </table>
<%}%>



<script language="javascript">
	window.print();
//window.setInterval("javascript:window.close();",0);
</script>

</body>
</html>
