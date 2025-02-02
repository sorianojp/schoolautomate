<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Blank. Do nothing.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<%
//get the file to be forwareded.
String strForward = (String)request.getSession(false).getAttribute("forward_url");
request.getSession(false).removeAttribute("forward_url");

if(strForward == null || strForward.trim().length() == 0)
{
	
}
%>
</html>