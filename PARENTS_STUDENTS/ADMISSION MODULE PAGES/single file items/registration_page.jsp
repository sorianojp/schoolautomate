<%
String strTempID = (String)request.getSession(false).getAttribute("tempId");
//System.out.println(" biswa ->"+strTempID);
if(strTempID != null && strTempID.trim().length() > 0)
{
	response.sendRedirect(response.encodeRedirectURL("./ADMISSION%20FOR%20NEW_TRANSFERRE%20STUDENTS/welcome.jsp"));
	return;
}
else if(true){	
	response.sendRedirect("./registration_new.jsp");
	return;
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ChangeValue(strCatgVal)
{
	document.startpage.appl_catg.value = strCatgVal;
}
function NewEnrollee() {
	strApplCatg = document.startpage.appl_catg.value;
	var strSecondCourse = "";
	if(document.startpage.appl_catg_radio[2].checked) {
		strSecondCourse = prompt('Please enter Previous course name.', '');
		if(strSecondCourse == null || strSecondCourse.length == 0) {
			alert("please enter previous course name.");
			return;
		}
	}
	location="./ADMISSION FOR NEW_TRANSFERRE STUDENTS/gspis_page.jsp?appl_catg="+escape(strApplCatg)+"&s_course="+
			escape(strSecondCourse);
}
function FocusID()
{
	document.startpage.user_id.focus();
}

</script>
<body bgcolor="#9FBFD0" onLoad="javascript:FocusID();">
<form name="startpage" action="../../../commfile/login.jsp" method="post" target="_parent">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F" align="center"><font color="#FFFFFF"><strong>:: 
        REGISTRATION ::</strong></font></td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td width="13%" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
<!---->
    <tr> 
      <td width="7%" bgcolor="#9FBFD0">&nbsp;</td>
      <td width="21%" height="25" >&nbsp;</td>
      <td colspan="3" bgcolor="#97AFB7"><div align="center"><font color="#FFFFFF"><strong>LOG 
          IN </strong></font></div></td>
      <td width="19%" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td bgcolor="#BECED3">Temporary 
        ID:&nbsp; </td>
      <td bgcolor="#BECED3"> 
        <input type="text" name="user_id" size="16" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">        </td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td bgcolor="#BECED3">Password 
        :&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </td>
      <td bgcolor="#BECED3"> 
        <input type="password" name="password" size="16" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">        </td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td bgcolor="#BECED3" align="center"><br> </td>
      <td bgcolor="#BECED3" align="center"><div align="left"> 
          <input name="image" type="image" src="../../../images/form_login.gif">
        </div></td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td colspan="2" bgcolor="#BECED3" align="center"><strong><br>
        (OR)<br>
        Register and Proceed to Enrollment &nbsp;</strong></td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
<!---->
    <tr> 
      <td width="7%" bgcolor="#9FBFD0">&nbsp;</td>
      <td width="21%" height="25" >&nbsp;</td>
      <td colspan="3" bgcolor="#97AFB7"><div align="center"><font color="#FFFFFF"><strong>Register</strong></font></div></td>
      <td width="19%" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td width="4%" height="25" bgcolor="#BECED3">&nbsp; </td>
      <td colspan="2" bgcolor="#BECED3"> 
        <input type="radio" name="appl_catg_radio" value="New" checked onClick='ChangeValue("New")'>
        New Applicant</td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td height="25" colspan="2" bgcolor="#BECED3"> 
        <input type="radio" name="appl_catg_radio" value="Transferee" onClick='ChangeValue("Transferee")'> Transferee
	  </td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td height="25" colspan="2" bgcolor="#BECED3">
        <input type="radio" name="appl_catg_radio" value="Second Course" onClick='ChangeValue("Second Course")'> Second Course (New)
	  </td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td height="25" bgcolor="#BECED3"><div align="left"><a href="javascript:NewEnrollee();" target="_self"><img src="../../../images/form_proceed.gif" border="0"></a></div></td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td height="25" bgcolor="#BECED3">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" bgcolor="#97AFB7">&nbsp;</td>
      <td width="15%" height="25" bgcolor="#97AFB7"> <div align="left"> </div></td>
      <td width="21%" bgcolor="#97AFB7">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td colspan="5" height="25" bgcolor="#FFFFFF"><div align="center"><strong> 
          <!--
		  Please login if you are already registerd or select your status and Proceed to continue registration.-->
		  Please select status and click proceed to continue registration
		  </strong></div></td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td colspan="5" height="25">&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
  </table>
  <input name="appl_catg" type="hidden" value="New">
  <input type="hidden" name="login_type" value="temp_stud">
  <input type="hidden" name="welcome_url" value="../PARENTS_STUDENTS/ADMISSION%20MODULE%20PAGES/single%20file%20items/ADMISSION%20FOR%20NEW_TRANSFERRE%20STUDENTS/index_newstud.htm">
</form>
</body>
</html>
