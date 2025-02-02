<%
if(request.getSession(false).getAttribute("userId") == null){%>
<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
	Please login to access this link.
</font>
<%return;
}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-To Do","acc_main.jsp");
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
%>
<body bgcolor="#8C9AAA">
<form action="acc_main.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="4" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          TO DO - ACCOMLISHMENTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="25%"  height="28">&nbsp;</td>
      <td width="50%" height="28"><div align="center"><a href="./acc_add.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;">ADD ACCOMPLISHMENT</a></div></td>
      <td width="25%" height="28">&nbsp;</td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28"><div align="center"><a href="./acc_view.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;">VIEW ACCOMPLISHMENTS</a></div></td>
      <td height="28">&nbsp;</td>
    </tr>
<%if(false){%>
     <tr> 
      <td height="28">&nbsp;</td>
      <td height="28"><div align="center"><a href="./acc_supervisor.jsp" target="organizermainFrame">SUPERVISOR - not used.</a></div></td>
      <td height="28">&nbsp;</td>
    </tr>
<%}%>
 	<tr> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
  </table>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>