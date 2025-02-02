<%
//show the links only if the student is logged in.";
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
String strUserId = (String)request.getSession(false).getAttribute("userId");
boolean bolIsStudent = false;
if(strUserId != null && strUserId.trim().length() > 0)
{
	if(strAuthIndex.compareTo("4") ==0 || strAuthIndex.compareTo("6") ==0)
		bolIsStudent = true;
}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/admissionmainmenu.css" rel="stylesheet" type="text/css">
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

function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var win=window.open("./gspis_print.jsp","PrintWindow",'scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
//-->
</script>
<link href="../../css/admissionmainmenu.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>

<body bgcolor="#578EAC" onLoad="MM_preloadImages('../../images/home_small_rollover.gif','../../images/help_small_rollover.gif','../../images/logout_rollover.gif')" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <form action="../../commfile/logout.jsp" method="post" target="_parent">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="../main_files/login_success.htm" target="bottomFrame" onMouseOver="MM_swapImage('Image1','','../../images/home_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image2','','../../images/help_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_rollover.gif',1)" onMouseOut="MM_swapImgRestore()">
        <input type="image" src="../../images/logout.gif" name="Image3" width="65" height="22" border="0" id="Image3">
        </a> </td>
    </tr>
    <input type="hidden" name="logout_url" value="../PARENTS_STUDENTS/ADMISSION%20MODULE%20PAGES/single%20file%20items/ADMISSION%20FOR%20NEW_TRANSFERRE%20STUDENTS/index_newstud.htm">
    <input type="hidden" name="body_color" value="#C39E60">
    <input type="hidden" name="login_type" value="temp_stud">
  </form>
  <tr>
    <td height="25" colspan="3" bgcolor="#86AEC4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>MAIN
        MENU</strong></font></div></td>
  </tr>
  <%
if(!bolIsStudent)
{%>
  <tr>
    <td height="19">&nbsp;</td>
    <td  colspan="2" class="admissionmainmenu"><em><font color="#FFFFFF" size="1" face="Geneva, Arial, Helvetica, sans-serif"><a href="../ADMISSION%20MODULE%20PAGES/single%20file%20items/registration_page.jsp" target="rightFrame"><img src="../../images/login_parent.gif" border="0"></a>click
      to login</font></em></td>
  </tr>
  <%}%>
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="organizational_membership.jsp" target="rightFrame">Membership</a></font></strong></td>
  </tr>
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2" class="admissionmainmenu"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../../faculty_acad/stud/stud_non_acad.jsp?is_student=1" target="rightFrame">Awards/Achievements</a></font></strong></td>
  </tr>
<% if (false) {%> 
  <tr>
    <td height="25"><img src="../../images/small_white_box.gif" width="4" height="6">&nbsp;</td>
    <td colspan="2"><strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif"><a href="../enrollment/schedule.htm" target="rightFrame">Activities</a></font></strong></td>
  </tr>
<%}%>
</table>
</body>
</html>
