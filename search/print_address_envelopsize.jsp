<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)	
	strSchCode = "";
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Print Address</title>
</head>
<body topmargin="0" bottommargin="0" onload="window.print();">
<font style="font-size:12px; font-family:Verdana, Arial, Helvetica, sans-serif; font">
<%
String strAddress = (String)request.getParameter("address");
if(strAddress == null)
	strAddress = "";
int iIndexOf = strAddress.indexOf("Tel#");
if(iIndexOf != -1) {
	int iIndexOf2 = strAddress.indexOf("<br>",iIndexOf);
	if(iIndexOf2 != -1)
		strAddress = strAddress.substring(0,iIndexOf)+"</font>"+strAddress.substring(iIndexOf2);
	else	
		strAddress = strAddress.substring(0,iIndexOf);
}
%>
<%if(strSchCode.startsWith("UB")){%>
	<br /><br /><br /><br /><br />
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="35%">&nbsp;</td>
			<td><%=strAddress%></td>
		</tr>
	</table>

<%}else{%>
	<%=strAddress%>
<%}%>

</font>
</body>
</html>
