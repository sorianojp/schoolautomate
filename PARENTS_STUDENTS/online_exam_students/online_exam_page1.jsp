<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
</script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.DBOperation" %>
<%
 
	DBOperation dbOP = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		//exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
%>

<form method="post" action="./online_exam_page2.jsp" name="ole_page1">
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F"> 
      <td height="25" colspan="5" ><div align="center"><strong><font color="#FFFFFF">:: 
          ONLINE EXAMINATION - TAKE EXAM - PAGE 1 ::</font></strong></div></td>
    </tr>
    
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td width="56%">&nbsp;</td>
    </tr>
    <tr> 
      <td width="26%">&nbsp;</td>
      <td width="18%">Student ID</td>
      <td> <input name="stud_id" type="hidden" size="20" 
	  value="<%=(String)request.getSession(false).getAttribute("userId")%>">
	  <font size="2"><b><%=(String)request.getSession(false).getAttribute("userId")%></b></font></td>
    </tr>
	    <tr> 
      <td width="26%">&nbsp;</td>
      <td width="18%">OR Number</td>
      <td> <input name="or_number" type="text" size="20"></td>
    </tr>

    <tr> 
      <td>&nbsp;</td>
      <td>Exam ID</td>
      <td><input name="exam_id" type="text" size="20">
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><input name="image" type="image" src="../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
<tr>
<td width="3%" height="25">
      <td align="center"><strong>Keep exam instruction here</strong></td>
</td>
</tr>
</table>
  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" colspan="2">&nbsp;</td>
    </tr>

    <tr> 
      <td colspan="2"><div align="center"> </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="exam_period_name">
</form>
</body>
</html>
