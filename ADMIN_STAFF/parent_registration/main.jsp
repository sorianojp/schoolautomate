<%@ page language="java" import="utility.*, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
a{
	text-decoration: none;
}
</style>
<title>Book Supply Log</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PARENT REGISTRATION"),"0"));		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security

	try{
		dbOP = new DBOperation();
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./main.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: PARENT REGISTRATION MAIN ::::</strong></font></div></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		<tr>
			<td colspan="2" height="25">&nbsp;</td>
		</tr>
		<tr>
		    <td height="25" align="right"></td>
		    <td width="68%"><a href="./parent_registration_module.jsp">REGISTER PARENT MODULE</a></td>
		</tr>
		
		<!--<tr>
		    <td height="25" align="right">&nbsp;</td>
		    <td width="68%"><a href="./view_registered_sms.jsp">VIEW/EDIT REGISTERED PARENT</a></td>
		</tr>-->
		<tr>
		    <td height="25" align="right">&nbsp;</td>
		    <td width="68%"><a href="./view_registered_parent.jsp">VIEW REGISTERED PARENT</a></td>
		</tr>
		<!--<tr>
		    <td height="25" align="right">&nbsp;</td>
		    <td width="68%"><a href="./change_password.jsp">CHANGE PASSWORD</a></td>
		</tr>-->
		
		<tr>
		    <td height="25" align="right">&nbsp;</td>
		    <td width="68%"><a href="./view_student_parent_not_reg.jsp">VIEW STUDENT PARENT NOT REGISTERED</a></td>
		</tr>		
		<tr>
		    <td height="25" align="right">&nbsp;</td>
		    <td width="68%"><a href="./assign_rfid.jsp">ASSIGN RFID TO LOGIN ID</a></td>
		</tr>
		<tr>
		    <td height="25" align="right">&nbsp;</td>
		    <td width="68%"><a href="./upload_parent_picture.jsp">UPLOAD PARENT PICTURE</a></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		</tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>