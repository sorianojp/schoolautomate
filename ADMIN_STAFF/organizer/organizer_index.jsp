<%
utility.WebInterface WI = new utility.WebInterface(request);
String strTemp = null;
if(WI.fillTextValue("is_parent").length() > 0) 
	strTemp = "?is_parent=1&my_home=1";
else if(WI.fillTextValue("my_home").length() > 0) 
	strTemp = "?my_home=1";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<frameset rows="*" cols="265,*" framespacing="0" frameborder="NO" border="0">
  <frame src="./organizer_links.jsp<%=WI.getStrValue(strTemp)%>" name="leftFrame"  >
  <frame src="./organizer_welcome_page.jsp" name="organizermainFrame">
</frameset>
<noframes><body>

</body></noframes>
</html>
