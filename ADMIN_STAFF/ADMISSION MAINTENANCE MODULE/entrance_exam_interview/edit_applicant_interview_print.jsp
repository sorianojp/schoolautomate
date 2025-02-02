<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Exam Result Encoding </title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vSchedData = null;
	String strErrMsg = null;
	String strTemp = null;
	int iCount = 0;
	int iCount2 = 1;

	String[] astrRemarks = {"Failed","Passed"};
	int iEncoded = 1;
	String strSchCode  = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW",
								"editr_applicant_interview.jsp");
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
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",
														request.getRemoteAddr(),"editr_applicant_interview.jsp");
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
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	vSchedData = appMgmt.operateOnInterview(dbOP, request, 4);

%>
<body>
<% if (strErrMsg  != null) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
    <tr>
      <td height="25" colspan="4"> &nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
<% } %>
<div align="center">
  <p><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></p>
</div>
<%
	if (WI.fillTextValue("view_set").equals("0") && vSchedData != null
			&& vSchedData.size() > 0) {
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="23" colspan="4" align="center" class="thinborder"><strong>APPLICANT INTERVIEW SCHEDULE</strong></td>
  </tr>
    <tr>
      <td width="11%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="19%" height="21" align="center" class="thinborder"><strong>
      TEMPORARY  ID</strong></td>
      <td width="46%" align="center" class="thinborder"><strong>APPLICANT NAME</strong></td>
      <td width="24%" align="center" class="thinborder"><strong>SCHEDULE</strong></td>
    </tr>
<% 	String[] astrPassFail = {"Fail", "Pass","Pending"};
	for (int t = 0; t < vSchedData.size() ; t+= 9) {%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount2++%><input type="hidden" name="user_index<%=iCount%>"
	  		value="<%=(String)vSchedData.elementAt(t)%>">&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp; <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vSchedData.elementAt(t+5)) +
	  					" (" +  WI.getStrValue((String)vSchedData.elementAt(t+6)) + ")"%>		</td>
    </tr>
    <%}%>
</table>
  <%
    }
	if (WI.fillTextValue("view_set").equals("1") && vSchedData != null
			&& vSchedData.size() > 0) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="23" colspan="4" align="center" class="thinborder"><strong>APPLICANT INTERVIEW RESULTS </strong></td>
    </tr>
    <tr>
      <td width="11%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="19%" height="21" align="center" class="thinborder"><strong>
      TEMPORARY  ID</strong></td>
      <td width="53%" align="center" class="thinborder"><strong>APPLICANT NAME</strong></td>
      <td width="17%" align="center" class="thinborder"><strong>RESULT</strong></td>
    </tr>
<% 	String[] astrPassFail = {"Fail", "Pass","Pending"};
	for (int t = 0; t < vSchedData.size() ; t+= 9) {%>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount2++%><input type="hidden" name="user_index<%=iCount%>"
	  		value="<%=(String)vSchedData.elementAt(t)%>">&nbsp;	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp; <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;
	  	<%=astrPassFail[Integer.parseInt(WI.getStrValue((String)vSchedData.elementAt(t+8),
													"2"))]%></td>
    </tr>
    <%}%>
</table>
<%
    }

  if (WI.fillTextValue("view_set").equals("2") &&
  		vSchedData != null && vSchedData.size() > 0) {  %>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="23" colspan="4" align="center" class="thinborder"><strong><font color="#000000">FINAL LIST OF APPLICANTS WITH SUBJECT(S) TO TAKE </font></strong></td>
  </tr>
    <tr>
      <td width="11%" align="center" class="thinborder"><strong>
      NO.</strong></td>
      <td width="19%" height="25" align="center" class="thinborder"><strong>
      TEMPORARY  ID</strong></td>
      <td width="45%" align="center" class="thinborder"><strong>APPLICANT NAME</strong></td>
      <td width="25%" align="center" class="thinborder"><strong>SUBJECT TO TAKE</strong></td>
    </tr>
<%  String[] astrREGEEME = {"REG", "EE","ME","EE and ME",""};
	for(int t = 0; t < vSchedData.size(); t+=9){ %>
    <tr>
	  <td height="25" align="right" class="thinborder">
  	  <%=iCount2++%>&nbsp;
	  <input type="hidden" name="stud_index<%=iCount%>"
	  							value="<%=(String)vSchedData.elementAt(t)%>">  	  </td>
      <td class="thinborder">&nbsp;&nbsp;
        <%=(String)vSchedData.elementAt(t+1)%></td>
      <td class="thinborder">&nbsp; <%=WI.formatName((String)vSchedData.elementAt(t+2),(String)vSchedData.elementAt(t+3),
							(String)vSchedData.elementAt(t+4),4)%></td>
      <td class="thinborder">&nbsp;<%=astrREGEEME[Integer.parseInt(WI.getStrValue((String)vSchedData.elementAt(t+7),"4"))]%></td>
    </tr>
    <%}%>
</table>
     <%
	 }

	%>
</body>
</html>
<%
dbOP.cleanUP();
%>
