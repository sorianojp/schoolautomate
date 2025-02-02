<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-OTHER EXCEPTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}




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

String strSYFrom = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");
String strStudID = WI.fillTextValue("stud_id");

String strPrintedBy    = null;
String strPrintedTime  = null;
String strNote         = null;
String strCurHist      = null;
String strStudCourseYr = null;
String strStudName     = null;


if(strStudID.length() > 0) {
	String strSQLQuery = "select fname, mname, lname, user_index from user_table where id_number = '"+strStudID+"' and is_valid =1 and auth_type_index = 4";
	String strStudIndex = null;
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strStudName = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
		strStudIndex = rs.getString(4);
	}
	rs.close();
	if(strStudIndex != null) {
		strSQLQuery = "select createdBy.fname, createdBy.mname, createdBy.lname, cit_temp_enrollment_permit.create_time, "+
						"note, cur_hist_index from cit_temp_enrollment_permit "+
						"join user_table as createdBy on (createdBy.user_index = cit_temp_enrollment_permit.created_by) "+
						" where stud_index = "+strStudIndex+
						" and sy_from ="+strSYFrom+" and semester = "+strSemester+
						" and cit_temp_enrollment_permit.is_valid = 1";
		rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
		if(rs.next()) {
			strPrintedBy    = WebInterface.formatName(rs.getString(1),rs.getString(2),rs.getString(3),4);
			strPrintedTime  = WI.formatDateTime(rs.getLong(4), 5);
			strNote         = rs.getString(5);
			strCurHist      = rs.getString(6);
		}
		rs.close();
		if(strCurHist != null) {
			strSQLQuery = "select course_code, year_level from stud_curriculum_hist "+
			"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
			" where cur_hist_index = "+strCurHist;//System.out.println(strSQLQuery);
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) {
				strStudCourseYr = rs.getString(1)+WI.getStrValue(rs.getString(2), " - ", "","");
			}
		}
	}
}
if(strNote == null) {
	dbOP.cleanUP();
	%>
	<font style="font-weight:bold; color:#FF0000">
		Permit Information not found.
	</font>
	<%return;

}

String[] astrConvertTerm = {"Summer","First Semester","Second Semester"};

%>
<body onLoad="window.print();">
<br><br><br>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="50%" height="25"><%=strStudName%></td>
      <td align="right"><%=astrConvertTerm[Integer.parseInt(strSemester)]%>, <%=strSYFrom%> - <%=Integer.parseInt(strSYFrom) + 1%></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><%=WI.fillTextValue("stud_id")%>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <%=strStudCourseYr%>
	  
	  </td>
    </tr>
    <tr> 
      <td colspan="2" height="200px">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><%=strPrintedBy%> &nbsp;&nbsp;&nbsp;&nbsp;<%=strPrintedTime%>
	  <div align="right">
	  	<%=strNote%>
	  </div>
	  </td>
    </tr>
  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>