<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Receivable Projection Links.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../jscript/date-picker.js"></script>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript">
function RemoveFile(strFileName) {
	document.form_.remove_file.value = strFileName;
	this.SubmitOnce('form_');
}
</script>
<body>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-REPORTS","rec_projection.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Accounting","REPORTS",request.getRemoteAddr(),
														"rec_projection.jsp");
dbOP.cleanUP();

if(iAccessLevel == -1)//for fatal error.
{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../commfile/unauthorized_page.jsp");
	return;
}
%>
<form name="form_" action="./rp_link.jsp" method="post">
<input type="hidden" name="remove_file">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><b>
	  <%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#CCCCCC"> 
      <td height="25" align="center" colspan="3">LIST OF RECEIVABLE PROJECTION 
        FILES AVAILABLE</td>
    </tr>
    <tr bgcolor="#FFFFAF"> 
      <td width="21%" height="25" align="center"><font size="1"><strong>SY - TERM</strong></font></td>
      <td width="68%" align="center"><font size="1"><strong>DOWNLOAD LINK</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>REMOVE</strong></font></td>
    </tr>
<tr><td height=25 align=center>&nbsp;</td>
<td align=center>(FILE SIZE)</td>
<td align=center><a href='javascript:RemoveFile("");'>
<img src="../images/delete.gif" border=0></a></td>
</tr>
<!--Insert here-->
	<tr bgcolor="#FFFFFF"> 
      <td height="25" align="center">&nbsp;</td>
      <td align="center">(FILE SIZE)</td>
      <td align="center"><a href='javascript:RemoveFile("");'>
	  <img src="../images/delete.gif" border="0"></a></td>
    </tr>
	
  </table>
</form>
</body>
</html>
