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
      <td height="25" colspan="2" bgcolor="#A49A6A" align="center"><font color="#FFFFFF" ><strong>:::: SPECIAL JOURNAL ::::</strong></font></td>
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
<%
String strTemp = request.getParameter("operation");
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
String strLoggedInUser = (String)request.getSession(false).getAttribute("userId");
if(strLoggedInUser == null)
	strLoggedInUser = "";
if(strTemp == null) 
	strTemp = "";
if(strTemp.compareTo("1") == 0){%>
  <tr> 
    <td width="12%" height="24">&nbsp;</td>
    <td width="15%" align="right">Operation : </td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./ar_journal.jsp">AR Journal - College</a></td>
  </tr>
  <tr> 
    <td width="12%" height="24">&nbsp;</td>
    <td width="15%" align="right"></td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./ar_journal.jsp?is_basic=1">AR Journal - Basic</a></td>
  </tr>
  <tr> 
    <td colspan="4"><hr size="1" color="#0000FF"></td>
  </tr>
  <tr> 
    <td width="12%" height="24">&nbsp;</td>
    <td width="15%" align="right"></td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./ar_journal.jsp?is_postcharge=1">AR Journal - Post Charge (Tuition) - College</a></td>
  </tr>
  <tr> 
    <td width="12%" height="24">&nbsp;</td>
    <td width="15%" align="right"></td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./ar_journal.jsp?is_basic=1&is_postcharge=1">AR Journal - Post Charge (Tuition) - Basic</a></td>
  </tr>
<%}else if(strTemp.compareTo("2") == 0){%>
  <tr> 
    <td width="12%" height="24">&nbsp;</td>
    <td width="15%" align="right">Operation : </td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./scholarship_journal.jsp">Scholarship - College</a></td>
  </tr>
  <tr> 
    <td width="12%" height="24">&nbsp;</td>
    <td width="15%" align="right"></td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./scholarship_journal.jsp?is_basic=1">Scholarship - Basic</a></td>
  </tr>
<%}else if(strTemp.compareTo("3") == 0){%>
  <tr> 
    <td width="12%" height="24">&nbsp;</td>
    <td width="15%" align="right">Operation : </td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./crj_tuition.jsp">Cash Receipt Journal Tuition 
	<!--(Tuition, Back account, oth sch fee - tuition - basic and college)--></a></td>
  </tr>
  <tr> 
    <td width="12%" height="24">&nbsp;</td>
    <td width="15%" align="right"></td>
    <td width="2%">&nbsp;</td>
    <td width="71%"><a href="./crj_tuition.jsp?non_tuition=1">Cash Receipt Journal Non-Tuition <!--(basic and college)--></a></td>
  </tr>
<%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
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
