<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Login</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="././css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<script language="JavaScript" type="text/JavaScript">
<!--
function NoHomeYet() {
	alert("HOME IS NOT FOUND.");
}


function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//-->
</script>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
-->
</style>
<body bgcolor="#32466B" text="#FFFF00" vlink="#FFFF00" alink="#FFFF00" topmargin="0" onLoad="MM_preloadImages('images/help_roll.gif','images/logout_roll.gif','images/home_roll.gif')">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="3" valign="bottom">&nbsp;
<%
String strUserID = (String)request.getSession(false).getAttribute("userId");
if(false && strUserID != null && strUserID.trim().length() > 0) {%>
	<a href="javascript:NoHomeYet();">My Home</a> <em><font size="1"> Go to personal page</font></em>
<%}//do not show if not logged in%>
	</td>
  </tr>
  <tr valign="bottom">
    <td colspan="3"><div align="right"><em><a href="./comment/comment_create.jsp" target="mainFrame"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Comments?</font></a></em><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<font color="#FFFFFF" size="1">Let
        us know</font></font></div></td>
  </tr>
  <tr>
    <td colspan="3"><hr size="1"></td>
  </tr>
<form action="../commfile/logout.jsp" method="post" target="_parent">
  <tr>
    <td width="12%"><a href="./index.jsp" onMouseOver="MM_swapImage('Image1','','images/home_roll.gif',1)" onMouseOut="MM_swapImgRestore()" target="_parent"><img src="images/home.gif" name="Image1" width="69" height="34" border="0" id="Image1"></a></td>
    <td width="14%"><a href="javascript:;" onMouseOver="MM_swapImage('Image2','','images/help_roll.gif',1)" onMouseOut="MM_swapImgRestore()">
	<img src="images/help.gif" name="Image2" width="49" height="34" border="0" id="Image2">
	</a></td>
    <td width="74%">
	<a onMouseOver="MM_swapImage('Image3','','images/logout_roll.gif',1)" onMouseOut="MM_swapImgRestore()">
<%
if(strUserID != null && strUserID.trim().length() > 0) {%>
	<input type="image" src="./images/logout.gif" name="Image3" border="0" id="Image3">
<%}%>	</a></td>
  </tr>
    <input type="hidden" name="logout_url" value="../lms">
    <input type="hidden" name="body_color" value="#C39E60">
  </form>
</table>
</body>
</html>
