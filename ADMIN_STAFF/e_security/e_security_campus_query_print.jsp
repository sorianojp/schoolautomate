<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
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

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

</style>
</head>
<body>
<%@ page language="java" import="utility.*,eSC.CampusQuery,java.util.Vector" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	String strReportToDisp = WI.fillTextValue("report_to_disp");
	String[] astrConvertToTerm ={"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eSecurity Check-Campus Query","e_security_campus_query.jsp");
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
														"eSecurity Check","STUDENTS CAMPUS ATTENDANCE QUERY",request.getRemoteAddr(), 
														"e_security_campus_query.jsp");	
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
int iSearchResult = 0;
CampusQuery CQ          = new CampusQuery(request);
vRetResult = CQ.getStudCampusQuery(dbOP,request);
if(vRetResult == null)
	strErrMsg = CQ.getErrMsg();
else	
	iSearchResult = CQ.getSearchCount();


if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center"><strong><%=strReportToDisp%></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><b> TOTAL RESULT : <%=iSearchResult%></b> </td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="19%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="57%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME<BR>(LNAME, FNAME, MI.) </strong></font></div></td>
    </tr>
    <%for(int i = 0; i< vRetResult.size(); i +=5){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i)%></font></td>
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+1),
	  (String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></font></td>
    </tr>
    <%}	%>
  </table>
  <%}//only if vRetResult is not null %>

</body>
</html>
<%
dbOP.cleanUP();
%>