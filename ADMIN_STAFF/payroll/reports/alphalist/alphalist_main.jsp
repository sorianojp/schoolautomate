<%@ page language="java" import="utility.*" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
 if(strSchCode == null)
	strSchCode = "";
	
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	boolean bolShowLink = false;
 	if(strUserID != null && (strUserID.equals("bricks") || strUserID.equals("GTI-01") || strSchCode.startsWith("UPH") ))
		bolShowLink = true;
%>
<body bgcolor="#D2AE72" class="bgDynamic">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      BIR ALPHALIST (TAX SCHEDULES)::::</strong></font></td>
    </tr>
	</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>  
	<tr>
	  <td height="25">&nbsp;</td>
	  <td height="25" align="right">&nbsp;</td>
	  <td><a href="encode_report_schedule74.jsp">Encode Previous Employer Income Details</a></td>
  </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td height="25" align="right">&nbsp;</td>
	  <td><a href="min_wage_earners.jsp">Minimum Wage Earners</a></td>
  </tr>
	<%if(strSchCode.startsWith("TSUNEISHI") || bolShowLink){%>
	<tr>
    <td height="25">&nbsp;</td>
    <td height="25" align="right">&nbsp;</td>
    <td><a href="form_1601c.jsp">Form 1601c</a></td>
  </tr>
	<%}%>
	<tr>
    <td height="25">&nbsp;</td>
    <td height="25" align="right">&nbsp;</td>
    <td><a href="form_2316.jsp">Form 2316</a></td>
  </tr>	
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="71%"><a href="report_schedule71.jsp">Schedule 
    7.1 </a>(<font color="#000000" size="1" ><strong>Terminated</strong></font>)</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td width="71%"><a href="report_schedule72.jsp">Schedule 
        7.2</a> <font color="#000000" size="1" ><strong>Exempt from withholding 
    Tax</strong></font></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td><a href="report_schedule73.jsp">Schedule 
        7.3</a> (<font color="#000000" size="1" ><strong>No Previous Employers 
    for the year)</strong></font></td>
  </tr>

  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td><a href="report_schedule74.jsp">Schedule 
        7.4</a> (<font color="#000000" size="1" ><strong>With Previous Employers 
    for the year)</strong></font></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td><a href="report_schedule75.jsp">Schedule 
        7.5</a> (<font color="#000000" size="1" ><strong>Minimum Wage Earners</strong></font>)</td>
  </tr>
	<%if(bolShowLink){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">&nbsp;</td>
    <td width="71%"><a href="report_schedule71old.jsp">Schedule 
    7.1 </a>(<font color="#000000" size="1" ><strong>Terminated</strong></font>)<font color="#000000" size="1" >(based on saved payroll) </font></td>
  </tr>	
 	<tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="71%"><a href="report_schedule72old.jsp">Schedule 
        7.2</a> <font color="#000000" size="1" ><strong>Exempt from withholding 
    Tax</strong>(based on saved payroll) </font></td>
  </tr>
	<tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="report_schedule73old.jsp">Schedule 
        7.3</a> <font color="#000000" size="1" ><strong>No Previous Employers 
    for the year </strong>(based on saved payroll) </font></td>
  </tr>	
	<tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td><a href="report_schedule74old.jsp">Schedule 
        7.4</a> <font color="#000000" size="1" ><strong>With Previous Employers 
    for the year </strong>(based on saved payroll) </font></td>
  </tr>	
	<%}%>
   <%if(bolShowLink){%>
	<tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td><a href="report_schedule_4.jsp">Schedule 4</a></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td><a href="report_schedule_5.jsp">Schedule 5 </a></td>
  </tr>
	<%}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr bgcolor="#A49A6A"> 
    <td width="100%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>

</body>
</html>
