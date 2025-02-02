<%
	String strErrMsg = (String)request.getSession(false).getAttribute("errorMessage");
	if(strErrMsg == null || strErrMsg.trim().length() == 0)
		strErrMsg = "";
	else
		request.getSession(false).removeAttribute("errorMessage");
		
//remove if there is any auth session attribute
	String strAuthReqd = (String)request.getSession(false).getAttribute("authrequired");
	if(strAuthReqd != null)
	{
		request.getSession(false).removeAttribute("authrequired");
	}
	
String strBodyColor = request.getParameter("body_color");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>



<body bgcolor="<%=strBodyColor%>">

<p>&nbsp;</p>
<p><br>
  
  <font size="3" face="Verdana, Arial, Helvetica, sans-serif">Error: <%=strErrMsg%></font> </p>

</body>

</html>

