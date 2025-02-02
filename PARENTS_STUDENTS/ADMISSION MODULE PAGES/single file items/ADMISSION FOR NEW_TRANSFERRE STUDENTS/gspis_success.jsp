<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#9FBFD0">
<form>
<form name="createlogin" action="./gspis_success.jsp" method="post" onSubmit="submitonce(this);">
<%@ page language="java" import="utility.*,enrollment.NAApplicationForm,enrollment.NAApplCommonUtil" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTempID = null;
	boolean bolSendEmail = true; //send email always.
	String strErrMsgEMail = null; // error in sending
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
strTempID = request.getParameter("temp_id");
if(strTempID == null || strTempID.trim().length() == 0)
{
	strErrMsg = "Please fill up GSPIS form.";
}
else //create Login information here.
{
	NAApplicationForm napplForm = new NAApplicationForm();
	if(!napplForm.createLoginInfo(dbOP,request))
		strErrMsg = napplForm.getErrMsg();
	else
	{
		//send this information to email id.
		NAApplCommonUtil comUtil = new NAApplCommonUtil();
		if(!comUtil.sendUserIDPassword(strTempID,request.getParameter("password"), request.getParameter("email")))
			strErrMsgEMail = comUtil.getErrMsg();
	}
}

dbOP.cleanUP();
%>

 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>::::
          GENERAL STUDENT PERSONAL INFORMATION SHEET (GSPIS) ::::</strong></font></div></td>
    </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%">&nbsp;</td>
	  <td width="91%">&nbsp;</td>
      <td width="5%">&nbsp;</td>

    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
<%
if(strErrMsg != null){%>
    <tr>
      <td colspan="3">&nbsp; <%=strErrMsg%></td>
    </tr>
<%return; }%>    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>

    <tr>
      <td colspan="3"></td>
    </tr>
    <tr>
      <td width="4%">&nbsp;</td>
	  <td width="91%"> You have successfully registered with the school.Please
        note your temporary ID and password given below. This Temporary ID will be used thru' the rest of the enrollment process. <br>
        <br>
        <font style="font-size:24px;"><u><b>Temporary ID : <%=strTempID%></b></u> - To be used in your enrollment process</font> <br>
        <br><b>Access Password: </b><%=request.getParameter("password")%> <br>
        You can get all
        necessary information about your admission appliaction procedure and application
        status. <br>
        <%
		  if(bolSendEmail) //send email
		  {
		  	if(strErrMsgEMail == null) //success
			{%>
        <br>
        <b>NOTE: </b>Your user id and password are sent to your email id : <%=request.getParameter("email")%> as provided.
			<%}else{%>
			<br><b>NOTE: </b> 
			1. Your user id and password could not be sent to your email id due to following error. But you are
			successfully registered to School. Please note down your user id and password to log on to system for Application
			process tracking.
			<br>
			2. Temporary ID shown will be used thru' rest of the enrollment process.
			<br><b>ERROR: </b><%=strErrMsgEMail%>
		<%
			}
		}%>


	  </td>
      <td width="5%">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="24%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="68%">
<!--
	  <a href="../registration_page.jsp"><img src="../../../../images/form_login.gif" border="0"></a>
-->
	  <a href="../../../main_files/login_new.jsp"><img src="../../../../images/form_login.gif" border="0"></a>
	  Please login to print GSPIS Form.</td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>

  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="6%">&nbsp;</td>
      <td width="94%"><strong><font color="#FF0000">NOTE :</font></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#000000" ><strong>GENERAL
        STUDENT PERSONAL INFORMATION SHEET (GSPIS) </strong>is the same form that
        shall be </font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#000000" >filled
        up and given</font> to the Guidance Office upon enrollment.</td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>

  </table>

</form>
</body>
</html>
