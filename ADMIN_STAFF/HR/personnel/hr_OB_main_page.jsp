<%@ page language="java" import="utility.*" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Official Business.</title>
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
      <td width="79%" colspan="2"><a href="./hr_employee_logout.jsp">Create Official Business (Specific Employee)</a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="./hr_apply_OB_batch.jsp">Create Official Business (Batch) </a></td>
    </tr>
    
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