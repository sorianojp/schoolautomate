<%
String strForwardURL = (String)request.getSession(false).getAttribute("logout_url");
request.getSession(false).removeAttribute("logout_url");
%>
<html>
<head>
<title>
HOME
</title>
</head>

<script>
function myFun()
{
	location.replace("./forbid.jsp");
	<%
	if(strForwardURL == null || strForwardURL.trim().length() ==0){%>
		history.go(+1);
	<%}else{%>
		location="<%=strForwardURL%>";//this is index.jsp
	<%}%>
	
}
</script>

<body onLoad="myFun();">
</body>
</html>
