<%@ page language="java" import="utility.*" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("auth_type_index");
boolean bolIsLoggedIn = true;
if(request.getSession(false).getAttribute("userIndex") == null)
	bolIsLoggedIn = false;
else if(strAuthTypeIndex != null) {
	int iAuthType = Integer.parseInt(strAuthTypeIndex);
	if(iAuthType < 4)
		bolIsLoggedIn = false;
}
if(!bolIsLoggedIn) {%>
	<p style="font-size:14px; color:#FF0000; font-weight:bold">You do not have Proper authentication</p>
<%}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      ABSENCES MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
	</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
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
    <td width="71%"><a href="./absences_encoding.jsp">Encode Absences</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./absences_encoding_report.jsp">View/Print Absence Record</a></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  
  <tr> 
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A"> 
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>

</body>
</html>
