<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
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
<body>
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.LoginActivity" %>
<%
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null; String strTemp3 = null;
	Vector vRetResult = new Vector();
	int iSearchResult =0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-Login activity","login_activity_print.jsp");
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
														"System Administration",
														"USER MANAGEMENT",request.getRemoteAddr(), 
														"login_activity_print.jsp");	
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
LoginActivity loginActivity = new LoginActivity();
	vRetResult = loginActivity.getLoginActivitySummary(dbOP, request);
	if(vRetResult == null)
		strErrMsg = loginActivity.getErrMsg();
	else {
		iSearchResult = loginActivity.getSearchCount();
	}

%>
<table width="100%" cellpadding="0" cellspacing="0">
  <tr> 
    <td> <div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        <br>
        <strong>LOGIN INFORMATION REPORT</strong> <br>
      </div></td>
  </tr>
  <tr>
    <td align="right">Date and Time printed :<%=WI.getTodaysDateTime()%> </td>
  </tr>
</table>
<%
if(strErrMsg != null){%>
<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
			<%=strErrMsg%>
		</td>
	</tr>
</table>
<%return;//do not worry, dbOP is already closed.
}%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  height="20" colspan="4" bgcolor="#E0E0E0"><div align="center">LOGIN 
          INFORMATION FOR DATE (<%=WI.getStrValue(WI.fillTextValue("from_date"),WI.getTodaysDate(1))%>
		  <%=WI.getStrValue(WI.fillTextValue("to_date")," to ","","")%>)</div></td>
    </tr>
  </table>
  
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="66%"  height="20"><b> TOTAL RESULT : <%=iSearchResult%> </b></td>
  </tr>
</table>
  
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="16%"  height="20"><div align="center"><font size="1"><strong>DATE(MM/DD/YYYY)</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>LOGIN ID</strong></font></div></td>
      <td width="26%"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>TIME-IN</strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>TIME-OUT</strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>LOGIN IP</strong></font></div></td>
      <td width="8%"><div align="center"><font size="1"><strong>LOGIN DURATION</strong></font></div></td>
<!--      <td width="9%"><div align="center"><strong><font size="1">VIEW WORK DETAIL</font></strong></div></td>
-->    </tr>
    <%for(int i = 0; i< vRetResult.size(); i +=7){%>
    <tr> 
      <td  height="20" align="center"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i))%></font></td>
      <td align="center"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+1))%></font></td>
      <td align="center"><font size="1"> <%=WI.getStrValue(vRetResult.elementAt(i+2))%></font></td>
      <td  height="20"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></div></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+4), "&nbsp;")%></font></div></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+6),"Not loggedout")%></font></td>
<!--      <td><div align="center"><img src="../../images/view.gif" border="0" ></div></td>
-->    </tr>
    <%}%>
  </table>
<script language="javascript">
window.print();
</script>
 
</body>
</html>
