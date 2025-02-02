<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) {%>
	<p style="font-size:14px; font-weight:bold; color:red">You are already logged out. Please login again.</p>
<%return;}

///check here if i should show re-advise link.
boolean bolShowReAdviseLink = false;
boolean bolShowNonEmployeeSetting = false;

if(strSchCode.startsWith("CIT"))
	bolShowNonEmployeeSetting = true;
else {
	utility.DBOperation dbOP = new utility.DBOperation();
	String strSQLQuery = "select prop_val from read_property_file where prop_name = 'ALLOW_READVISE'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null && strSQLQuery.equals("0"))
		bolShowReAdviseLink = true;
	
	strSQLQuery = "select prop_val from read_property_file where prop_name = 'ENABLE_NON_EMPLOYEE_SETTING'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null && strSQLQuery.equals("0"))
		bolShowNonEmployeeSetting = true;
	dbOP.cleanUP();
}

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" style="font-weight:bold; color:#FFFFFF" align="center">:::: OTHER SYSTEM SETTING ::::</td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UC") || strSchCode.startsWith("UB") || 
strSchCode.startsWith("CDD") || true){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Enrollment : </td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./eto.jsp">Create ETO Personnel</a> </td>
  </tr>
<%if(strSchCode.startsWith("DLSHSI")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./allow_duplicate_name.jsp">Allow Duplicate Name</a></td>
  </tr>
<%}if(strSchCode.startsWith("CIT")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./allow_second_advise.jsp">Allow Re-Advising</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./allow_duplicate_name.jsp">Allow Duplicate Name</a></td>
  </tr>
<%}
}if(bolShowReAdviseLink) {%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./allow_second_advise.jsp">Allow Re-Advising</a></td>
  </tr>
<%}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./class_program_su.jsp">Allow Users to Create Class Program for Other Colleges/Courses</a></td>
	<!-- class program super user -->
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./exclude_subject_block_section.jsp">Exclude subject from Block sectioning</a></td>
	<!-- class program super user -->
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%">&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("CIT")){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./allow_dropping_nstp_pe_subject.jsp">Allow Dropping NSTP/PE subject</a></td>
  </tr>
<%}
if(bolShowNonEmployeeSetting){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./set_as_non_employee.jsp">Set user as Non-Employee</a></td>
  </tr>
<%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A"> 
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
