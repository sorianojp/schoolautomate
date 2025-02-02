<%@ page language="java" import="utility.*"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;

if ((new CommonUtil().getIsSchool(null)).equals("1")) 
	bolIsSchool = true;
String strUserId = (String)request.getSession(false).getAttribute("userId");
boolean bolShowAll = false;
if(strUserId != null && strUserId.equals("bricks"))
	bolShowAll = true;
%>
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
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="2" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      SALARY/BENEFITS/INCENTIVES MANAGEMENT PAGE ::::</strong></font></td>
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
    <td width="71%"><a href="./sal_ben_incent_mgmt_sal.jsp"><% if (bolIsSchool){%>Academic Rank /<%}%> Job 
      Grade Management</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./sal_ben_incent_mgmt_benefits.jsp?IS_BENEFIT=0">Benefit 
      Management</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./sal_ben_incent_mgmt_incentive.jsp?IS_BENEFIT=1">Incentive Management</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./sal_ben_auto_insert.jsp">Insert Auto Apply Incentives / Benefits </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./sal_ben_auto_insert_res.jsp">Restricted Employee Incentives / Benefits </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./sal_benefit_encode_restrict.jsp">Benefit Restriction Management </a></td>
  </tr>
	<tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="./sal_ben_batch_close.jsp">Batch Close Benefits / Incentives </a></td>
  </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td height="25">&nbsp;</td>
	  <td align="center">&nbsp;</td>
	  <td><a href="./emp_benefits.jsp">Employee Benefits / Incentives </a></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" width="1%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A" class="footerDynamic"> 
    <td width="1%" height="25">&nbsp;</td>
  </tr>
</table>

</body>
</html>
