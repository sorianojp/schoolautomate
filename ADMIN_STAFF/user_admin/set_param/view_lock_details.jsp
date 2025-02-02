<%@ page language="java" import="utility.*, enrollment.SetParameter, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>View Details</title>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameter","view_lock_details.jsp");

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
															"System Administration","Set Parameters",request.getRemoteAddr(),
															"lock_cur.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	//end of authenticaion code.
	
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	String[] astrLockTarget = {"", "Grade Releasing", "Report Card", "TOR"};
	String[] astrLockView = {"Unlocked", "Lock All", "Lock Print Only"};
	
	String strInfoIndex = WI.fillTextValue("info_index");
	if(strInfoIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Lock credential access reference not found. 
		Please close this window and click the view link again from main window.</p>
		<%return;
	}
	
	SetParameter sp = new SetParameter();
	
	Vector vRetResult = sp.operateOnLockCredential(dbOP, request, 3);
	if(vRetResult == null)
		strErrMsg = sp.getErrMsg();
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_lock_details.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::: LOCK CREDENTIAL ACCESS DETAILS :::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Student Name: </td>
	  	    <td width="80%"><%=WebInterface.formatName((String)vRetResult.elementAt(3), (String)vRetResult.elementAt(4), (String)vRetResult.elementAt(5), 4)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>ID Number: </td>
			<td><%=(String)vRetResult.elementAt(2)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>SY/Term:</td>
			<td><%=(String)vRetResult.elementAt(6)%>-<%=Integer.parseInt((String)vRetResult.elementAt(6)) + 1%>/
				<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(7))]%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Lock Target: </td>
			<td><%=astrLockTarget[Integer.parseInt((String)vRetResult.elementAt(8))]%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Lock View: </td>
			<td><%=astrLockView[Integer.parseInt((String)vRetResult.elementAt(9))]%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Lock Reason: </td>
			<td><%=(String)vRetResult.elementAt(10)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Encoded By: </td>
			<td><%=WebInterface.formatName((String)vRetResult.elementAt(13), (String)vRetResult.elementAt(14), (String)vRetResult.elementAt(15), 4)%> (<%=(String)vRetResult.elementAt(12)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Create Date: </td>
			<td><%=(String)vRetResult.elementAt(16)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Unlock Reason: </td>
			<td><%=WI.getStrValue((String)vRetResult.elementAt(17))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Unlocked By: </td>
			<td>
				<%
					if((String)vRetResult.elementAt(18) == null)
						strTemp = "&nbsp;";
					else{
						strTemp = WebInterface.formatName((String)vRetResult.elementAt(20), (String)vRetResult.elementAt(21), (String)vRetResult.elementAt(22), 4);
						strTemp += " ("+(String)vRetResult.elementAt(19)+")";
					}
				%><%=strTemp%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date Unlocked: </td>
			<td><%=WI.getStrValue((String)vRetResult.elementAt(23))%></td>
		</tr>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="info_index" value="<%=strInfoIndex%>"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>