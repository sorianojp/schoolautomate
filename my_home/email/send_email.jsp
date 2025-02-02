<%@ page language="java" import="utility.*, hr.HRNotification"%>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userId") == null){%>
		<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
			Please login to access this link.
		</font>
		<%return;
	}
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Send Email</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript" src="../../jscript/common.js"></script>
</head>
<script language="javascript">
function SendEmail() {
	if(document.form_.to_addr.value == '') {
		alert("Please enter recepient's email address.");
		return;
	}
	if(document.form_.subject.value == '') {
		alert("Please provide email subject.");
		return;
	}
	if(document.form_.msg.value == '') {
		alert("Please provide email msg.");
		return;
	}
	document.form_.page_action.value = "1";
	document.form_.submit();
}

function SearchEmployee(){
	var pgLoc = "searchEmailAddress.jsp?my_home=1&opner_info=form_.to_addr&address="+document.form_.to_addr.value;
	var win=window.open(pgLoc,"SearchEmployee",'dependent=yes,width=700,height=500,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ClearAll(){
	document.form_.page_action.value = "";
	document.form_.to_addr.value = "";
	document.form_.subject.value = "";
	document.form_.msg.value = "";
	document.form_.submit();
}

</script>
<style>
a:link {
	color: #000000;
	text-decoration: none;
}
a:visited {
	color: #000000;
	text-decoration: none;

}
a:hover {
	font-weight: bold;
	color: #000000;
	text-decoration: underline;

}
a:active {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
</style>
<%
	DBOperation dbOP = null;
	boolean bResult = false;
	
	String strErrMsg = null;
	String strTemp = null;
	String strEmailAdd = null;
	String strSubject = null;
	String strMessage = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"), "my_home","send_email.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	HRNotification hrNot = new HRNotification();
	String strSendersEmail = null;
	strSendersEmail = hrNot.getSendersEmail(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
	if(strSendersEmail == null)
		response.sendRedirect("../my_home_welcome_page.jsp");
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.equals("1")){
		strEmailAdd = WI.fillTextValue("to_addr");
		strSubject = WI.fillTextValue("subject");
		strMessage = WI.fillTextValue("msg");
		utility.MailUtil mu = new utility.MailUtil(strSendersEmail);
		if(mu.SendTextMail(strEmailAdd, strSubject, strMessage, true) == true)
			strErrMsg = "Email sent successfully.";
		else
			strErrMsg = "Email not sent.";
	}
%>
<body bgcolor="#D2AE72" onLoad="document.form_.to_addr.focus();">
<form action="./send_email.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      	<td height="28" colspan="6" bgcolor="#A49A6A" align="center">
			<font color="#FFFFFF" ><strong>:::: SEND EMAIL MESSAGE ::::</strong></font>
		</td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    	<tr>
		<td colspan="6" height="10">Send to: <font size="1">[enter fields separated by commas]</font></td>    
	</tr>
    	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
	<tr>
    	<td>&nbsp;</td>
    	<td align="left"><strong>Email Address: </strong></td>
    	<td colspan="4"><div align="left">
			<input name="to_addr" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" size="64" value="<%=WI.fillTextValue("to_addr")%>">
				<a href="javascript:SearchEmployee()"><img src="../../images/search.gif" border="0"></a>
			</div>
		</td>
    </tr>
   	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
    <tr>
    	<td>&nbsp;</td>
    	<td align="left"><strong>Subject</strong></td>
    	<td colspan="4"><div align="left">
    		<input name="subject" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" size="64" value="<%=WI.fillTextValue("subject")%>"></div>
		</td>
    </tr>
    <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
    <tr>
    	<td>&nbsp;</td>
    	<td valign="top" align="left"><strong>Message</strong></td>
    	<td colspan="4">
    	<%strTemp = WI.fillTextValue("msg");%>
    	<textarea name="msg" cols="75" rows="15" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
	
    <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
		<tr>
		<td colspan="6" align="center"><font size="1">
		<a href="javascript:SendEmail();"><img src="../../images/send_email.gif" border="0" ></a>Send Email&nbsp;&nbsp;&nbsp;  
		<a href="javascript:ClearAll()"><img src="../../images/clear.gif" border="0"></a>Clear fields
		</td>    
	</tr>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="page_action">
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>