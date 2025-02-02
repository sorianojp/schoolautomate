
<%
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName =(String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName = strUserId;
if(strName == null) strName = "";



String strUserIDField = "_"+Long.toString(new java.util.Date().getTime());
String strPwdField    = strUserIDField + "0";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Login Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function FocusID()
{
	<%
	if(strUserId == null || strUserId.trim().length() == 0)
	{%>
	document.dwform1.<%=strUserIDField%>.focus();
	<%}%>
}
function FDK_setFormText(form,name,text) {
  textobject = eval('document.'+form+'.'+name);
  textobject.value = text;
  //alert(document.dwform1.dwfield1.value);
}
function submitForm() {
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.forms[0].style.visibility = "hidden";
}
</script>
<body bgcolor="#D2AE72" onLoad="javascript:FocusID();">
<%
//I have to get here if pin code authentication is applicable. 
boolean bolPCProtect = false;
utility.ReadPropertyFile rProp = new utility.ReadPropertyFile();
utility.WebInterface WI        = new utility.WebInterface(request);
String strPCProtect = rProp.getImageFileExtn("PINCODE_PROTECTION","0");
if(strPCProtect.equals("1"))
	bolPCProtect = true;

if(strUserId == null || strUserId.trim().length() == 0)
{
String strErrMsg = request.getParameter("errorMessage");
if(strErrMsg == null) strErrMsg = "";%>
<form name="dwform1"  action="../../commfile/login.jsp" method="post" target="_top" autocomplete="off">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><b><%=strErrMsg%></b></font></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="18%">&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="thinborderALL"><div align="center"><font color="#FFFFFF"><strong>Please 
          Login</strong></font></div></td>
      <td width="18%">&nbsp;</td>
    </tr>
    <tr align="center"> 
      <td>&nbsp;</td>
<%
String strErrForwarded = (String)request.getSession(false).getAttribute("err_");
if(strErrForwarded != null) {
	request.getSession(false).setAttribute("err_", null);
}
%>
      <td height="45" colspan="3" bgcolor="#FFFFFF" class="thinborderLEFTRIGHT" style="font-weight:bold; font-size:18px; color:#FF0000"><%=WI.getStrValue(strErrForwarded)%>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="15%" height="25" bgcolor="#FFFFFF" class="thinborderLEFT">&nbsp;</td>
      <td width="12%" bgcolor="#FFFFFF" class="thinborderNONE">Login ID/Name </td>
      <td width="37%" bgcolor="#FFFFFF" class="thinborderRIGHT">
	  <input type="text" name="<%=strUserIDField%>"  class="username_field" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" autocomplete="off">
	  <input type="hidden" name="user_id"  value="<%=strUserIDField%>">	  </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="22" bgcolor="#FFFFFF" class="thinborderLEFT">&nbsp;</td>
      <td height="22" bgcolor="#FFFFFF" class="thinborderNONE">Password</td>
      <td height="22" bgcolor="#FFFFFF" class="thinborderRIGHT">
	  <input type="password" name="<%=strPwdField%>"  class="password_field" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" autocomplete="off">
	  <input type="hidden" name="password"  value="<%=strPwdField%>">
	  <input type="hidden" name="is_secured" value="1"><!-- this is must to provide 1-->	  </td>
      <td>&nbsp;</td>
   </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="29" bgcolor="#FFFFFF" class="thinborderLEFT">&nbsp;</td>
      <td height="29" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="29" valign="middle" bgcolor="#FFFFFF" class="thinborderRIGHT"><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <!--<input type="image" src="../../images/form_login.gif">-->
	  <input type="submit" name="Login" value="Login Here" onClick="submitForm();">
	  
	  <br>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#FFFFFF" class="thinborderLEFTRIGHT" align="center">&nbsp;
	  <%if(bolPCProtect){%>
	  <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0" width="250" height="250" title="key">
      <param name="movie" value="pincode_UI.swf">
      <param name="quality" value="high">
      <embed src="pincode_UI.swf" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="250" height="250"></embed>
    </object>
	  <%}%>	  </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#FFFFFF" class="thinborderLEFTRIGHT"><div align="center"><strong>New 
          user?</strong> Please contact system administrator for your username 
          and password.</div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#FFFFFF" class="thinborderLEFTRIGHT">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="thinborderALL">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="body_color" value="#D2AE72">
<!-- relative to commfile
<input type="hidden" name="welcome_url" value="../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm">
 -->
<input type="hidden" name="welcome_url" value="../ADMIN_STAFF/admin_staff_index.htm">
<input type="hidden" name="page_url" value="../ADMIN_STAFF/admin_staff_index.htm">
<input type="hidden" name="login_type" value="admin_staff">
<%
/**
* dwfield1 = pincode entered.
* dwfield2 = new pincode
* dwfiled3 = retype pincode.
**/
if(bolPCProtect) {%>
<input type="hidden" name="dwfield1">
<input type="hidden" name="dwfield2">
<input type="hidden" name="dwfield3">
<%}%>
</form>
<%}else{%>
		<jsp:forward page="./admin_staff_welcome_page.jsp" />

<p align="center"> <font size="3"> Current user : <b><%=strName%></b>. Please 
  continue or logout to change user.</font></p>
<%}%>

<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
