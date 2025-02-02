<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function SendMail() {
	document.form_.hide_mail.src = "../images/blank.gif";
	document.form_.send_email_level.value = "Sending .... ................. ";
	document.form_.submit();
}
</script>
<body bgcolor="#46689B">
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ViolationConflict"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-VIOLATIONS & CONFLICTS","send_main_violation.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","VIOLATIONS & CONFLICTS",request.getRemoteAddr(),
														"send_main_violation.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult = null;//It has all  violation information.
Vector vMailInfo  = null;
String strInfoIndex = WI.fillTextValue("info_index");
ViolationConflict VC = new ViolationConflict();
String strListOfEmailIDNotFound = null;

if(strInfoIndex.length() > 0) {
	vRetResult = VC.operateOnViolation(dbOP, request,3);
	if(vRetResult == null)
		strErrMsg = VC.getErrMsg();
	else {
		vMailInfo = VC.collectEmailAddrOfStud(dbOP, (String)vRetResult.elementAt(13));
		if(vMailInfo == null)
			strErrMsg = VC.getErrMsg();
		else {
			if(vMailInfo.elementAt(1) != null)
				strListOfEmailIDNotFound =
				"List of Changed party without parents email ID information : "+
					vMailInfo.elementAt(1);
		}
	}
}
else
	strErrMsg = "Violation reference is missing.Please try again to send email.";


String strName = (String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName ="<NOT FOUND>";

//authenticate the user here.
String strEmailTo = WI.fillTextValue("to");
boolean bolIsCommaSeparated = false;
if(vMailInfo != null && WI.fillTextValue("content").length() > 0 && strEmailTo.length() > 0) {
	MailUtil mailUtil = new MailUtil();
	if(strEmailTo.indexOf(",") != -1)
		bolIsCommaSeparated = true;
	if(!mailUtil.SendTextMail(strEmailTo,WI.fillTextValue("subject"),
									WI.fillTextValue("content"), bolIsCommaSeparated))
	{
		strErrMsg = mailUtil.getErrMsg();
	}
	else {
		strErrMsg = "Send mail successful.";
		//I have to increase the count of emails sent.
		VC.sendMailSuccessFul(dbOP, strInfoIndex);
	}
}

dbOP.cleanUP();
%>
<form method="post" name="form_" action="./send_mail_violation.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#004488">
      <td height="26" colspan="3"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOOLBLIZ WEBMAIL ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size=3>&nbsp;</font></td>
      <td height="25" colspan="2"><font size=3><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
<%
if(strListOfEmailIDNotFound != null){%>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size=3>&nbsp;</font></td>
      <td height="25" colspan="2"><font size=3><strong>
	  <%=WI.getStrValue(strListOfEmailIDNotFound)%></strong></font></td>
    </tr>
<%}%>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom"><div align="center"><strong><font size="3">WELCOME
          <%=strName.toUpperCase()%> TO THE SCHOOLBLIZ WEBMAIL PAGE!</font></strong></div></td>
    </tr>
    <tr >
      <td height="25" colspan="3"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
<%
if(strErrMsg == null && vRetResult != null && vRetResult.size() > 0 &&
	vMailInfo != null && vMailInfo.size() > 0 ){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="5%" height="25">&nbsp;</td>
      <td width="10%" valign="top">TO (Separate with comma)</td>
      <td width="85%"><textarea name="to" cols="65" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=WI.getStrValue(vMailInfo.elementAt(0))%></textarea>
      </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td valign="top">FROM</td>
      <td><input name="from" type="text" class="textbox_noborder"
	  value="<%=(String)vMailInfo.elementAt(5)%>" size="32">
        (Return Address)</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td valign="top">SUBJECT</td>
      <td> <input name="subject" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=(String)vMailInfo.elementAt(2)%>" size="67"></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td valign="top">CONTENT</td>
      <td><textarea name="content" cols="65" rows="20" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=(String)vMailInfo.elementAt(3)%>

	  Detail of Conflict/Violation :
	  CASE # : <%=(String)vRetResult.elementAt(6)%>
	  Date of Violation : <%=(String)vRetResult.elementAt(4)%>
	  Date Reported : <%=(String)vRetResult.elementAt(5)%>
	  Conflict/Violation Type : <%=(String)vRetResult.elementAt(8)%>
	  Incident : <%=(String)vRetResult.elementAt(8)%>
	  Charged Party : <%=(String)vRetResult.elementAt(13)%>
	  Complainant : <%=(String)vRetResult.elementAt(16)%>

	  Description : <%=(String)vRetResult.elementAt(9)%>

	  Action Taken : <%=(String)vRetResult.elementAt(10)%>

	  Recommendation : <%=(String)vRetResult.elementAt(11)%>


<%=vMailInfo.elementAt(4)%>
	  </textarea></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="2"><div align="right">
          <a href="javascript:SendMail();">
		  <img src="../images/send_email.gif" border="0" name="hide_mail"></a>
          <input name="send_email_level" type="text" class="textbox_noborder"
	  value="CLICK TO SEND EMAIL" size="32"> &nbsp;&nbsp;</div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%}//only if strErrmsg == nul%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#004488">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
