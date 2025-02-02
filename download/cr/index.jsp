
<%@ page import="java.io.*" %>
<HTML>
<HEAD>
<TITLE>Index of Files</TITLE>
</HEAD>

<BODY>
<H1>Index of Files</H1>
<%
String file = application.getRealPath("/download/cr/");

File f = new File(file);
String [] fileNames = f.list();
File [] fileObjects= f.listFiles();
%>
<UL>
<%
for (int i = 0; i < fileObjects.length; i++) {
	if(fileNames[i].equals("index.jsp"))
		continue;

if(!fileObjects[i].isDirectory()){
%>
<LI>
<A HREF="<%= fileNames[i] %>"><%= fileNames[i] %></A>
&nbsp;&nbsp;&nbsp;&nbsp;
[<%= Long.toString(fileObjects[i].length()) %> bytes]
<%
}
}
%>
</UL>
</BODY>
</HTML>