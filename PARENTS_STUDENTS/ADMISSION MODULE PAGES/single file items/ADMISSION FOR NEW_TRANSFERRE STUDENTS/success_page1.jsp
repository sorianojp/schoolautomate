<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.NAApplicationForm,java.util.Vector, java.util.Date,enrollment.NAApplCommonUtil" %>
<%
 //only used to load the combo box in the course offered drop list.
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTempId = null;
	String strErrMsgEMail = null;//registration is success.

	boolean bolSendEmail = false;

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

NAApplicationForm naApplForm = new NAApplicationForm();
if(naApplForm.createForm1(dbOP, request))
{
	strTempId = naApplForm.getTempId();
	//send emaill now if it is chosen.
	if(request.getParameter("send_temp_id") != null && request.getParameter("send_temp_id").compareTo("1") ==0)
	{
		bolSendEmail = true;
		NAApplCommonUtil comUtil = new NAApplCommonUtil();
		if(!comUtil.sendUserIDPassword(strTempId,request.getParameter("password"), request.getParameter("email")))
		{
			strErrMsgEMail = comUtil.getErrMsg();
		}
	}
}
else
	strErrMsg = naApplForm.getErrMsg();


dbOP.cleanUP();

%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="28" bgcolor="#47768F">&nbsp;</td>
      <td height="28" colspan="3" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          MY PERSONAL ONLINE ADMISSION PAGE ::::</strong></font></div></td>
      <td height="28" bgcolor="#47768F">&nbsp;</td>
    </tr>
    <tr>
      <td height="28" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="28" colspan="3" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="28" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
<%
if(strErrMsg != null)
{%>
<tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><%=strErrMsg%></td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
<%return;
}%>
    <tr>
      <td height="25" bgcolor="#9FBFD0"><div align="center"><strong></strong></div></td>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">WELCOME
        <%=request.getParameter("fname")%> <%=request.getParameter("mname")%>
        <%=request.getParameter("lname")%> </font><font color="#000000" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>
        TO ONLINE ADMISSION PAGE</strong>!</font></strong></div></td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td width="8%" height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td width="4%"><p align="justify">&nbsp;</p>
        <p>&nbsp;</p></td>
      <td width="80%"><p align="justify"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">You
        have successfully registered with the school.Please note that you can
        user your user id and password given below <br><br><b>user id:</b><%=strTempId%> <br>
        <b>Password: </b><%=request.getParameter("password")%> <br>
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
			<br><b>NOTE: </b> Your user id and password could not be sent to your email id due to following error. But you are
			successfully registered to School. Please note down your user id and password to log on to system for Application
			process tracking.
			<br><b>ERROR: </b><%=strErrMsgEMail%>
		<%
			}
		}%>
        </font></p>
		</td>
      <td width="3%">&nbsp;</td>
      <td width="5%" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
      <td height="25" bgcolor="#9FBFD0">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="28" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
