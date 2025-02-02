<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>
<head>
<title>Welcome to Online Library Management System</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

<%
	utility.DBOperation dbOP = new utility.DBOperation();
	String strSchCode = dbOP.getSchoolIndex();
	dbOP.cleanUP();
	
	if(strSchCode == null)
		strSchCode = "";
	if(strSchCode.startsWith("AUF")){
		response.sendRedirect("http://library.auf.edu.ph");
		return;
	}
String strLoginSuccess = "./maincontent.jsp";

String strUserID = (String)request.getSession(false).getAttribute("userId");
//System.out.println(strLStat);
if(strUserID != null && strUserID.trim().length() > 0 )
{
	strLoginSuccess = "./loginsuccess.jsp";	
}//System.out.println(strUserID);
%>
</head>

<frameset rows="80,336*" cols="*" frameborder="NO" border="0" framespacing="0">
  <frame src="top.htm" name="topFrame" scrolling="NO" noresize >
  <frameset rows="*" cols="227,*" framespacing="1" frameborder="yes" border="0" bordercolor="#CCCCCC">
    <frameset rows="*,48" cols="*" framespacing="0" frameborder="NO" border="0">
      <!--<frameset rows="83,*" cols="*" framespacing="0" frameborder="NO" border="0">
        <frame src="loginframe.jsp" name="topFrame1" scrolling="NO" noresize >-->
        <frame src="./main_menu_links.jsp" name="leftFrame"  noresize>
      <!--</frameset>-->
      <frame src="announcement.jsp" name="bottomFrame" scrolling="NO" noresize>
    </frameset>
    <frameset rows="*,48" cols="*" framespacing="1" frameborder="yes" border="0">
      <frame src="<%=strLoginSuccess%>" name="mainFrame">
      <frame src="copyright.htm" name="bottomFrame1" scrolling="NO" noresize>
    </frameset>
  </frameset>
</frameset>
<noframes><body>

</body></noframes>
</html>
