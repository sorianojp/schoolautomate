<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function submitonce(theform)
{
//if IE 4+ or NS 6+
	//form is submitted here.
	if (document.all||document.getElementById)
	{
	//screen thru every element in the form, and hunt down "submit" and "reset"
		for (i=0;i<theform.length;i++)
		{
			var tempobj=theform.elements[i]
			if(tempobj.type.toLowerCase()=="submit"||tempobj.type.toLowerCase()=="reset")
			//disable em
			tempobj.disabled=true
		}
	}
}

</script>

<body bgcolor="#9FBFD0" onLoad="document.createlogin.password.focus();">

<form name="createlogin" action="./gspis_success.jsp" method="post" onSubmit="submitonce(this);">
<%@ page language="java" import="utility.*,enrollment.NAApplicationForm" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTempID = null;

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//create the user information only if no temp id is created and
if(request.getParameter("appl_catg") == null || request.getParameter("appl_catg").trim().length() == 0)
{
	strErrMsg = "Please fill up GSPIS form.";
}
else //create information here.
{
	//check if temp id is created already.
	strTempID = request.getParameter("temp_id");
	if(strTempID == null || strTempID.trim().length() ==0)
	{
		//strErrMsg = "Please fill up GSPIS form.";
		//create the temp user here.
		NAApplicationForm napplForm = new NAApplicationForm();
		if(napplForm.createTempStud(dbOP,request))
		{
			strTempID = napplForm.getTempId();
		}
		else
			strErrMsg = napplForm.getErrMsg();
	}
}

dbOP.cleanUP();
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>::::
          GENERAL STUDENT PERSONAL INFORMATION SHEET (GSPIS) :::: </strong></font></div></td>
    </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%
if(strErrMsg != null)
{%>
<tr>
      <td width="28%" height="20" colspan="2">&nbsp; <strong>Error in GSPIS Form: Please go back and correct the errors :</strong> <br><br> Error Description: <br>
	  <b><%=strErrMsg%></b></td>
    </tr>
<%return ;}%>    <tr bgcolor="#BECED3">
      <td height="25" colspan="2"><font color="#FFFFFF"><strong><font color="#FFFFFF" >&nbsp;
        <font size="2"></font></font>:: <font color="#FFFFFF" ><font size="2">SYSTEM
        LOGIN INFORMATION</font></font></strong></font></td>
    </tr>
    <tr>
      <td width="28%" height="20">&nbsp; Temp. Student ID</td>
      <td width="72%"><b><%=strTempID%></b></td>
    </tr>
    <tr>
      <td>&nbsp; Password</td>
      <td height="20"><input name="password" type="password" maxlength="32"></td>
    </tr>
    <tr>
      <td height="20">&nbsp; Confirm Password</td>
      <td height="20"><input name="r_type_password" type="password" maxlength="32"></td>
    </tr>
    <tr>
      <td height="20">&nbsp; Forget Password? </td>
      <td height="20"><select name="forgot_pass_ques">
          <option value="1" selected>What is your pet name</option>
          <option value="2">What is your favourite color</option>
          <option value="3">What is your mother's maiden name</option>
          <option value="4">What is your best friends name</option>
          <option value="5">What is your favourite Flower</option>
          <option value="6">What is your food</option>
          <option value="7">Keep an arbitray answer.</option>
        </select> <font size="1">&nbsp; </font></td>
    </tr>
    <tr>
      <td height="20" valign="top"><em>&nbsp; Hint Question.</em></td>
      <td height="20" valign="top"><font size="1">(optional) - used if you forget
        your password. </font></td>
    </tr>
    <tr>
      <td height="20">&nbsp; Hint Question Answer</td>
      <td height="20"><input type="text" name="forgot_pass_ans" maxlength="64">
        <font size="1">(optional) </font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20"><input type="image" src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="temp_id" value="<%=strTempID%>">
  <input type="hidden" name="email" value="<%=WI.fillTextValue("email")%>">
</form>
</body>
</html>
