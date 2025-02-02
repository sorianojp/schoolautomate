<%@ page language="java" import="utility.*, projMgmt.GTIProjectTodo, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){%>
		<p style="font-size:16px; color:#FF0000;">You are logged out.</p>
		<%return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	String strInfoIndex = WI.fillTextValue("info_index");
	if(strInfoIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Todo reference is not found. Please close this window and click link again from main window.</p>
		<%return;
	}
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Project Management-View Details","view_details.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	Vector vRetResult = null;
	GTIProjectTodo proj  = new GTIProjectTodo();
	
	vRetResult = proj.operateOnProjectTodo(dbOP, request, 3);
	if(vRetResult == null)
		strErrMsg = proj.getErrMsg();	
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="view_details.jsp">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: TODO DETAILS PAGE ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25"><font size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>	
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="22%">Project:</td>
			<td width="75%"><%=(String)vRetResult.elementAt(4)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Client:</td>
			<td><%=WI.getStrValue((String)vRetResult.elementAt(2))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Category:</td>
			<td><%=(String)vRetResult.elementAt(32)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Priority:</td>
			<td><%=(String)vRetResult.elementAt(7)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Work Desc Short: </td>
			<td><%=(String)vRetResult.elementAt(8)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Work Desc Long: </td>
			<td rowspan="2" valign="top"><%=(String)vRetResult.elementAt(9)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Start Date: </td>
			<td><%=(String)vRetResult.elementAt(10)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>End Date: </td>
			<td><%=(String)vRetResult.elementAt(11)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Status:</td>
			<td>
				<%if(((String)vRetResult.elementAt(16)).equals("1")){%>
					Acknowledged
				<%}else{%>
					Pending
				<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Remarks:</td>
			<td><%=(String)vRetResult.elementAt(14)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Completion %: </td>
			<td><%=CommonUtil.formatFloat((String)vRetResult.elementAt(16), false)%>%</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Is Finished? </td>
			<td>
				<%if((String)vRetResult.elementAt(13) != null){%>
					Yes
				<%}else{%>
					No
				<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Assigned To: </td>
			<td>
				<%=WebInterface.formatName((String)vRetResult.elementAt(18), (String)vRetResult.elementAt(19), (String)vRetResult.elementAt(20), 4)%>
				(<%=(String)vRetResult.elementAt(17)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Assigned By: </td>
			<td>
				<%=WebInterface.formatName((String)vRetResult.elementAt(22), (String)vRetResult.elementAt(23), (String)vRetResult.elementAt(24), 4)%>
				(<%=(String)vRetResult.elementAt(21)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Originally Assigned To: </td>
			<td>
				<%=WebInterface.formatName((String)vRetResult.elementAt(26), (String)vRetResult.elementAt(27), (String)vRetResult.elementAt(28), 4)%>
				(<%=(String)vRetResult.elementAt(25)%>)</td>
		</tr>		
	</table>	
<%}%>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<!--this is the todo_index from main page-->
	<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
