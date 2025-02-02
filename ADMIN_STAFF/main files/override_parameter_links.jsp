<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="CACHE-CONTROL" content="no-cache"/> 
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<link href="../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">

<script language="JavaScript" type="text/JavaScript">
<!--
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

<style>
body{
scrollbar-base-color: #BC7E41
}
</style>
</head>

<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../images/home_small_admin_rollover.gif','../../images/help_small_admin_rollover.gif','../../images/logout_admin_rollover.gif')">
<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strErrMsg = null;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolGrantAll = false;
if(strUserId != null)
{
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}

	if(strErrMsg == null)
	{
		//check if user has filled up the form.
		//check here the authentication of the user. 
		if(comUtil.IsSuperUser(dbOP,strUserId))
			bolGrantAll = true;	//grant all ;-)
	}
}
else
	strErrMsg = "";

boolean isAuthorized = false;
		
//System.out.println("testing : strErrMsg ="+strErrMsg);
if(strErrMsg != null && strErrMsg.length() > 0)
{%>
<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="2"><b><%=strErrMsg%></b></font>
<%//System.out.println("testing");
if(dbOP != null) dbOP.cleanUP();
return;
}%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <form action="../../commfile/logout.jsp" method="post" target="_parent">
    <tr> 
      <td bgcolor="#E9E0D1" width="6%">&nbsp;</td>
      <td height="25" bgcolor="#E9E0D1"><a href="./admin_staff_home_button_content.htm" target="_parent" onMouseOver="window.status='Go back to home page'; MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1); return true" onMouseOut="MM_swapImgRestore()" ><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"> 
        <input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a></td>
    </tr>
    <input type="hidden" name="logout_url" value="../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm">
    <input type="hidden" name="body_color" value="#C39E60">
  </form>
  <tr> 
    <td height="10">&nbsp;</td>
    <td height="10" class="admissionmainmenu">&nbsp;</td>
  </tr>
  <% 
if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Override Parameters","STUDENT LOAD")!=0){isAuthorized=true;%>
  <tr> 
    <td width="6%" height="20"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td width="94%" height="20" class="admissionmainmenu"><strong>
	<font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">
	<a href="../user_admin/override_student_load.jsp" target="rightFrame">Student 
      Load </a></font></strong></td>
  </tr>
  <%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Override Parameters","GRADE SHEET ENCODING")!=0){isAuthorized=true;%>
  <tr> 
    <td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
      <a href="../user_admin/set_param_gs.jsp" target="rightFrame">Grade Sheet 
      Encoding</a></font></strong></td>
  </tr>
  <%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Override Parameters","ALLOW PREREQUISITE")!=0){isAuthorized=true;%>
  <tr> 
    <td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
    <td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
      <a href="../user_admin/override_param/allow_prereq.jsp" target="rightFrame">Allow Pre-requisite Subject</a></font></strong></td>
  </tr>
  <%}
  if(strSchCode.startsWith("NEU")){
	  if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Override Parameters","ALLOW ADD-DROP")!=0){isAuthorized=true;%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		  <a href="../user_admin/override_param/allow_online_adddrop.jsp" target="rightFrame">Allow Add/Drop </a></font></strong></td>
	  </tr>
	  <%}if(bolGrantAll || comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Override Parameters","HOLD-UNHOLD")!=0){isAuthorized=true;%>
	  <tr> 
		<td height="22"><img src="../../images/small_white_box.gif" width="4" height="6"></td>
		<td height="22" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"> 
		  <a href="../user_admin/set_param/hold_unhold_student.jsp?override_param=1" target="rightFrame">Hold - UnHold Student</a></font></strong></td>
	  </tr>
  <%}
  }%>
</table>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>