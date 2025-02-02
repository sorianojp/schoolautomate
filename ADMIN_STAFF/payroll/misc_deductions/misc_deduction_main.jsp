<%@ page language="java" import="utility.*" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
 if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Misc Deduction Main Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        MISCELLANEOUS DEDUCTIONS MAIN PAGE ::::</strong></font></td>
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
    <td height="25"><a href="./post_ded_preload_mgmt.jsp">Miscellaneous deductions management</a></td>
  </tr>
  
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./post_ded.jsp">Post deduction per employee</a></td>
  </tr>
  <tr> 
    <td height="26">&nbsp;</td>
    <td height="26">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./misc_ded_batch.jsp">Post deduction by batch </a></td>
  </tr> 
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./recurring_ded.jsp">Post recurring deductions</a></td>
  </tr>
  
  <%if(strSchCode.startsWith("UC")){%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./misc_ded_restrict_list.jsp">Make Employee Restriction for Deductions</a></td>
  </tr>
  <%}%>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
</body>
</html>
