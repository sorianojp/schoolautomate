<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
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
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
<body>
<%@ page language="java" import="utility.*,enrollment.ReportFaculty,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strCourseIndex = request.getParameter("course_index");
	String strMajorIndex  = request.getParameter("major_index");

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;
	String strCommonSubMsg = null;

	//this is necessary for different types of subject offering.
	//degree_type=0->UG,1->Doctoral,2->medicine,3->with prep proper, 4-> care giver.
	//for care giver,doctoral, do not show year level, for prep_prop, show prep/prop status.
	String strDegreeType = null;

	Vector vTemp = null;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-REPORTS"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}


	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-load schedule","list_of_subjects_no_faculty_print.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"list_of_subjects_no_faculty_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
**/

//end of authenticaion code.

ReportFaculty rf = new ReportFaculty();
Vector vRetResult = null;

	vRetResult = rf.getSectNoFac(dbOP,request);
	
	if(vRetResult == null) strErrMsg = rf.getErrMsg();
	


%>

<%=WI.getStrValue(strErrMsg,"")%>

  <% if (vRetResult != null && vRetResult.size() > 0) { %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="60%" height="25">&nbsp; Total Sections Found  : <%=vRetResult.size()/11%></td>
      <td width="40%"><div align="right"></div></td>
    </tr>
  </table> 
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="31" colspan="9" class="thinborder"><div align="center"><strong>LIST OF SUBJECTS 
          NOT YET ASSIGNED TO FACULTIES</strong><strong></strong></div></td>
    </tr>
    <tr> 
      <td width="7%" class="thinborder"><strong><font size="1">SUBJECT CODE</font></strong></td>
      <td width="26%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">SECTION</font></strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1">SCHEDULE (Days::Time)</font></strong></div></td>
      <td width="7%"  class="thinborder"><div align="center"><strong><font size="1">ROOM #</font></strong></div></td>
      <td width="6%"  class="thinborder"><div align="center"><strong><font size="1">(LEC/ LAB)</font></strong></div></td>
      <td width="7%"  class="thinborder"><div align="center"><strong><font size="1">TOTAL UNITS</font></strong></div></td>
      <td width="8%" height="25"  class="thinborder"><div align="center"><strong><font size="1">TOTAL 
          NO. OF STUDS.</font></strong></div></td>
      <td width="20%"  class="thinborder"><div align="center"><strong><font size="1">COLLEGE OFFERING</font></strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=11) {%>
    <tr> 
      <td height="33" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+10)%></font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+6)%> </font></td>
    </tr>
    <%}%>
  </table>
<%}%>
<script language="javascript">
	window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
