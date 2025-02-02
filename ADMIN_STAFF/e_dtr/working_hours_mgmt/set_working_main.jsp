<%@ page language="java" import="utility.*" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(7);

boolean bolIsRestricted = false;//if restricted, can only use the emplyee from same college/dept only.
if(request.getSession(false).getAttribute("wh_restricted") != null)
	bolIsRestricted = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Working Schedule Main Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style type="text/css">
	a {
		text-decoration:none;
		color: #FF0000;
	}
</style>
</head>
<body bgcolor="#D2AE72" class="bgDynamic">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        WORKING HOURS MGMT - SET WORKING HOURS PAGE ::::</strong></font></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%" align="right">Operation:&nbsp;&nbsp;</td>
      <td width="79%" colspan="2"><a href="./set_working.jsp">Create Working Hour for Specific Employee (weekday)</a></td>
    </tr>
	<%if(!bolIsRestricted) {%>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2"><a href="./set_working_multiple.jsp">Create Working Schedule for Multiple Employees</a></td>
		</tr>
	<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="./set_working_day.jsp?specify_wh=1">Create Working Hour for Employee (specific day)</a></td>
    </tr>
	<%if(!bolIsRestricted) {%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2"><a href="./set_working_day_batch.jsp">Create Working Hour for Multiple Employees (specific day)</a></td>
		</tr>
	<%}%>
	<%if(bolIsRestricted) {%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2"><a href="../dtr_operations/dtr_update_all.jsp">Recompute Working Hour</a></td>
		</tr>
	<%}%>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">Create Weekly Schedule for Junior and Senior Staff </td>
    </tr>
-->
    <tr> 
      <td height="43" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" colspan="4" class="footerDynamic">&nbsp;</td>
    </tr>	
  </table>
</body>
</html>