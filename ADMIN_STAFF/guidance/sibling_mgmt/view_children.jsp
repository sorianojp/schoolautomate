<%@ page language="java" import="utility.*, enrollment.PersonalInfoManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	String strParentIndex = WI.fillTextValue("parent_index");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View Children</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body bgcolor="#8C9AAA">
<form name="form_" action="./view_children.jsp" method="post">
<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Sibling Management","view_children.jsp");
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
															"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
															"view_children.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{

		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	Vector vRetResult = null;
	PersonalInfoManagement pim = new PersonalInfoManagement();
	
	vRetResult = pim.LinkSibling(dbOP, request, 4, strParentIndex);
%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F">
			<td height="25" colspan="2" align="center"><font color="#FFFFFF">
				<strong>::::  CHILDREN ::::</strong></font></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td><strong><font color="#FF0000" size="2"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	    </tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="center" class="thinborder" width="10%"><strong>Count</strong></td>
			<td align="center" class="thinborder" width="25%"><strong>ID Number </strong></td>
			<td align="center" class="thinborder" width="50%"><strong>Student Name </strong></td>
			<td align="center" class="thinborder" width="15%"><strong>Gender</strong></td>
		</tr>
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td align="center" class="thinborder">
				<%
					strTemp = (String)vRetResult.elementAt(i+3);
					if(strTemp.equals("M"))
						strTemp = "Male";
					else
						strTemp = "Female";
				%><%=strTemp%></td>
		</tr>
	<%}%>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
<%}%>
	
	<input type="hidden" name="parent_index" value="<%=strParentIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>