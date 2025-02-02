<%@ page language="java" import="utility.*"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Substitutions Main page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
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
      <td height="25" colspan="2" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      PAYROLL :  SUBSTITUTIONS MAIN PAGE ::::</strong></font></td>
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
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./faculty_subs.jsp">Substitution for salary period only </a></td>
   </tr>
   <%
 	 if(strSchCode.startsWith("WNU")){%>
   <tr>
     <td height="25">&nbsp;</td>
     <td height="25">&nbsp;</td>
     <td align="center">&nbsp;</td>
     <td><a href="./faculty_sem_subs_wnu.jsp">Substitution for whole semester</a></td>
   </tr>
	 <%}else{%>
   <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./faculty_sem_subs.jsp">Substitution for whole semester </a></td>
  </tr>
	<%}%>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25">&nbsp;</td>
  </tr>
</table>
</body>
</html>
