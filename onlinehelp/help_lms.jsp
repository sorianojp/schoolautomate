<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.sql.*" errorPage="" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
<style media="print">
body
{
display:none;
}
</style>
</head>
<!--
done - 
	select and copy(ctrl+c) - right click or left click
	print
	save as - not needed because there is no file menu.. 
to be done - 
	print scr - not yet - can stop only in IE.
to stop from disabling all these feature if jscript is disabled - 
use document.write.
-->
<script language="javascript" src="../jscript/selectnprint.js"></script>
<script language="javascript">
function CleanClipBoard() {
	if (!document.all){//do nothing
		//do nothing.
		//setInterval("window.clipboardData.setData('text','')",20);
	}
	else if (document.all){//IE
		setInterval("window.clipboardData.setData('text','')",20);
	}
}
</script>
<body onLoad="CleanClipBoard();">
<!-- onkeypress="return disableCtrlKeyCombination(event);" onkeydown="return disableCtrlKeyCombination(event);">onblur='window.clipboardData.setData("Text", "");'>-->
This is a page with no save as, no print, no print scr, no right click
and no select.
<script language="javascript">
document.write('This is a <b>test.</b>');
</script>
</body>
</html>
