<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Admission</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-size: 11px;
    }
</style>
</head>
<script language="javascript">
function PrintPage(){
	document.getElementById('header').deleteRow(5);
	window.print();	
}
</script>
<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector,enrollment.CourseRequirement"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;	
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

	//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Admission","Registration",request.getRemoteAddr(),null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"ADMISSION MAINTENANCE","ADMISSION SLIP",request.getRemoteAddr(),null);
}														
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
	String strSYFrom   = null;
	String strSYTo     = null;
	String strSemester = null;
	String strApplicationStat = null;
	String strStudName = null;
	String strYrLevel  = null;
	String strCourse   = null;
	String strMajor    = null;
	
	String strStudID = (String)request.getAttribute("old_id");
	if(strStudID != null) {
		strStudID = dbOP.mapUIDToUIndex(strStudID);
		if(strStudID == null) {
			strErrMsg = "Student ID not found.";
		}
		else {
			String strSQLQuery = "select sy_from, sy_to, semester, appl_catg, fname, mname, lname, year_level, course_offered.course_code, major.course_code from na_old_stud "+
				" join user_table on (user_table.user_index = na_old_stud.user_index) "+
				" join course_offered on (course_offered.course_index = na_old_stud.course_index) "+
				" left join major on (major.major_index = na_old_stud.major_index) "+
				" where na_old_stud.user_index = "+strStudID+" and na_old_stud.is_valid = 1";
			java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) {
				strSYFrom   = rs.getString(1);
				strSYTo     = rs.getString(2);
				strSemester = rs.getString(3);
				
				strApplicationStat = rs.getString(4);
				strStudName = WebInterface.formatName(rs.getString(5), rs.getString(6), rs.getString(7), 4);
				
				strYrLevel  = rs.getString(8);
				
				strCourse   = rs.getString(9);
				strMajor    = rs.getString(10);
			}
			rs.close();
			if(strSYFrom == null) {
				strErrMsg = "Student Enrolling Information not found.";
			}
		}
	}
	else {
		strErrMsg = "Please enter student ID.";
	}
	
	
	String[] astrSemester = {"Summer", " 1st Semester ", "2nd Semester", "3rd Semester "};
%>
<body bgcolor="#FFFFFF" onLoad="<%if(strErrMsg == null) {%>window.print()<%}%>">

<%if(strErrMsg != null){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="18"><font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
  </table>
<%}%>
<%if(strErrMsg == null){%>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="2%" height="2">&nbsp;</td>
        <td width="98%" align="center">
		<font size="3">
			<strong><%=SchoolInformation.getSchoolName(dbOP,false,false)%></strong></font>
				<br>
			<font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>		</td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td align="center" style="font-weight:bold;">BOARD OF ADMISSIONS </td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td align="center" style="font-weight:bold;">&nbsp;</td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td>
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td width="43%">Student ID No&nbsp;&nbsp;&nbsp;&nbsp;: <b><%=request.getAttribute("old_id")%></b></td>
					<td width="21%">&nbsp;</td>
					<td width="36%">Term & SY: <b><%=astrSemester[Integer.parseInt(strSemester)]%>, <%=strSYFrom%>-<%=strSYTo.substring(2)%></b></td>
				</tr>
				<tr>
				  <td>Name of Student: <b><%=strStudName%></b></td>
				  <td>Course &amp; Year: <b><%=WI.getStrValue(strCourse)%><%=WI.getStrValue(strMajor,"(",")","")%> - <%=WI.getStrValue(strYrLevel, "N/A")%></b></td>
		          <td width="36%">Admission Status: <b><%=strApplicationStat%></b></td>
			  </tr>
				<tr>
				  <td height="10" style="font-size:13px; font-weight:bold">&nbsp;</td>
				  <td  style="font-size:13px; font-weight:bold">&nbsp;</td>
				  <td style="font-size:13px; font-weight:bold">&nbsp;</td>
			  </tr>
			</table>		</td>
      </tr>
    </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr> 
      <td width="18" height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">
		  <table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="90%" valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td colspan="6">Approved for Enrollment
					      by: </td>
						</tr>
						<tr>
						  <td colspan="6">&nbsp;</td>
					  </tr>
						<tr>
						  <td width="31%" class="thinborderBottom">&nbsp;</td>
					      <td width="2%">&nbsp;</td>
					      <td width="31%" class="thinborderBottom">&nbsp;</td>
					      <td width="2%">&nbsp;</td>
					      <td width="31%" class="thinborderBottom">&nbsp;</td>
					      <td width="2%">&nbsp;</td>
					  </tr>
						<tr align="center">
						  <td>OAS</td>
						  <td>&nbsp;</td>
						  <td>SAO</td>
						  <td>&nbsp;</td>
						  <td>Dept Chair </td>
						  <td>&nbsp;</td>
					  </tr>
					</table>
				</td>
			  <td valign="top">&nbsp;</td>
			</tr>	  
		  </table>
	  </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td width="432" height="18">Prepared by: <b><%=(String)request.getSession(false).getAttribute("first_name")%></b></td>
      <td width="398" height="18" align="right" style="font-weight:bold"><%=WI.getTodaysDate(6)%></td>
    </tr>
  </table>
<%}%>
</body>
</html>
<% 
dbOP.cleanUP();
%>