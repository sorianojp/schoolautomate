<%@ page language="java" import="utility.*,lms.LmsAcquision,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);



//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Acquisition".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#FAD3E0">
<form action="./report_generation.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#0D3371">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: REPORTS ::::</strong></font></div></td>
    </tr>
</table>
  <jsp:include page="./inc.jsp?pgIndex=8"></jsp:include>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr><td align="center" height="25"><a href="reports/book_acquisition_profile.jsp" target="_self"><font color="#000000">Book Acquisition Profile</font></a></td></tr>
	<tr><td align="center" height="25"><a href="reports/budget_running_balance.jsp" target="_self"><font color="#000000">Budget Running Balance</font></a></td></tr>
	<tr><td align="center" height="25"><a href="reports/budget_performance_prev_year.jsp" target="_self"><font color="#000000">Budget Performance</font></a></td></tr>
	
	
	
	
		
  </table>
</form>
</body>
</html>
