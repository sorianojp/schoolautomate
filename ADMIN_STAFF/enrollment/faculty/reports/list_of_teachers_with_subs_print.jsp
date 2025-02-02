<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;
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


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-substitute-REPORTS","list_of_teachers_with_subs_print.jsp");
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
														"list_of_teachers_with_subs_print.jsp");
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
enrollment.FacMgmtSubstitution facSubs = new enrollment.FacMgmtSubstitution(dbOP);
Vector vRetResult   = null;
vRetResult = facSubs.facListWithSubs(dbOP, request);
if(vRetResult == null)
	strErrMsg = facSubs.getErrMsg();

if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="7" class="thinborder"><div align="center"><strong>LIST OF TEACHER(S) 
          WITH SUBSTITUTION</strong><strong></strong></div></td>
    </tr>
    <tr> 
      <td width="15%" height="25" class="thinborder"><div align="center"><strong><font size="1">SUBSTITUTING 
          INSTRUCTOR</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1"> INSTRUCTOR SUBSTITUTED</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">SUBS. DATE</font></strong></div></td>
      <td width="25%" class="thinborder"><div align="center"><strong><font size="1">SUBJECT</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">SECTION</font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1">SCHEDULE /ROOM 
          #</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">TOTAL NO. OF STUDS.</font></strong></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 10){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%><br><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td valign="middle" class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%> </td>
      <td valign="middle" class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td valign="middle" class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i + 8)%></div></td>
    </tr>
<%}//end of for loop.%>
  </table>
<script language="javascript">
	window.print();
</script>

<%}///end of vRetResult

if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><font size="3"><b><%=strErrMsg%></b></font></td>
    </tr>
	</table>

<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
