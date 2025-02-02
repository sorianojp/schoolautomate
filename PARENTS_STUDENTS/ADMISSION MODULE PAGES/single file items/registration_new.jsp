<%
String strTempID = (String)request.getSession(false).getAttribute("tempId");
//System.out.println(" biswa ->"+strTempID);
if(strTempID != null && strTempID.trim().length() > 0)
{
	response.sendRedirect(response.encodeRedirectURL("./ADMISSION%20FOR%20NEW_TRANSFERRE%20STUDENTS/welcome.jsp"));
	return;
}
///strTempID = request.getParameter("forward_");
//if(strTempID != null && strTempID.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Schoolautomate - Login and Registration</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../main_files/login_new.css" rel="stylesheet" type="text/css">

<!--Start to select radio button from a tr onclick-->
<script class="jsbin" src="../../main_files/login_new.js"></script>  
  <script type="text/javascript">
$(function() {
    $('tr').click(function(event) {                        
        if(event.target.type != "radio") {
            var that = $(this).find('input:radio');
            that.attr('checked', true);//!that.is(':checked'));
        }		
    });
});  
function GoToLogin() {
	location = "../../main_files/login_new.jsp";
} 
function ChangeValue(strCatgVal)
{
	document.startpage.appl_catg.value = strCatgVal;
}
function NewEnrollee() {
	strApplCatg = document.startpage.appl_catg.value;
	if(strApplCatg.length == 0) {
		alert("Please select Applcation Category");
		return;
	}
	var strSecondCourse = "";
	if(document.startpage.appl_catg_radio[1].checked || document.startpage.appl_catg_radio[2].checked || document.startpage.appl_catg_radio[3].checked) {
		strSecondCourse = prompt('Please enter Previous course name.', '');
		if(strSecondCourse == null || strSecondCourse.length == 0) {
			alert("please enter previous course name.");
			return;
		}
	}
	
	location="./ADMISSION FOR NEW_TRANSFERRE STUDENTS/gspis_page.jsp?appl_catg="+escape(strApplCatg)+"&s_course="+
			escape(strSecondCourse);
}
  </script>
<!--Start to select radio button from a tr onclick-->

</head>
<body>
<form name="startpage" onSubmit="return false;">

<div class='maincontainer'>
<div class='holderlogin'>
<div class='signage'>Registration</div>
<div><br>&nbsp;</div>
<div class='boxregister' style="height:230px;">
<div class='boxtable'>
<table width='100%' colspan='2' cellspacing='0' cellpadding='0' border='0' class='tableradio'>
	<tr onClick='ChangeValue("New")'>
		<td width='30%' align='right'><div class='boxradio'><input type='radio' name='appl_catg_radio'></div></td>
		<td width='70%'>New Applicant</td>
	</tr>
	<tr onClick='ChangeValue("Transferee")'>
		<td width='30%' align='right'><div class='boxradio'><input type='radio' name='appl_catg_radio'></div></td>
		<td width='70%'>Transferee</td>
	</tr>
	<tr onClick='ChangeValue("Second Course")'>
		<td width='30%' align='right'><div class='boxradio'><input type='radio' name='appl_catg_radio'></div></td>
		<td width='70%'>Second Course (New)</td>
	</tr>
	<tr onClick='ChangeValue("Cross Enrollee")'>
		<td width='30%' align='right'><div class='boxradio'><input type='radio' name='appl_catg_radio'></div></td>
		<td width='70%'>Cross Enrollee</td>
	</tr>
</table>
<table width='100%' cellspacing='0' cellpadding='0' border='0'  class='tableradiox'>
	<tr>
		<td height="60" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <input name="submit" type='submit' value='Register' border="0" onClick="NewEnrollee()"></td>
	</tr>
	<tr>
		<td><a href="javascript:GoToLogin();"><font style="color:#000000">Already Registered? Click here to login</font></a></td>
	</tr>
</table>
</div>
</div>
</div>

</div>

  <input name="appl_catg" type="hidden" value="">
  <input name="forward_" type="hidden" value="">

</form>
</body>
</html>
