<%
	if(request.getSession(false).getAttribute("userIndex") == null){%>
		<p style="font-size:16px; color:#FF0000;">You are logged out.</p>
		<%return;
	}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">

<title>Messages</title>
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#D2AE72">
<br />
<jsp:include page="tabs.jsp?pgIndex=7"></jsp:include>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
		<tr>
		    <td height="25" width="30%" align="right">Operation:</td>
		    <td width="2%">&nbsp;</td>
		    <td width="68%"><a href="message_create.jsp">
				<font color="#FF0000" size="2"><strong>Compose Message</strong></font></a></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="message_inbox.jsp"><font color="#FF0000" size="2"><strong>Messages</strong></font></a></td>
		</tr>
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="3" height="25">&nbsp;</td>
		</tr>
	</table>
</body>
</html>
