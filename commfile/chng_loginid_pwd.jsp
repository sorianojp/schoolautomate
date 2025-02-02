<%
String strBGCol = request.getParameter("bgcol");
String strHeaderCol = request.getParameter("headercol");
if(strBGCol == null || strBGCol.trim().length() ==0)
	strBGCol = "D2AE72";
else
	strBGCol = strBGCol;
if(strHeaderCol == null || strHeaderCol.trim().length() ==0)
	strHeaderCol = "A49A6A";
else
	strHeaderCol = strHeaderCol;	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Change Password</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">

<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}
-->
</style>
</head>
<script language="JavaScript">
function ChangePassword()
{
	document.form_.changePassword.value = 1;
}
function CheckInitID() {
	var strID = document.form_.new_uid.value;
	var strInitID = document.form_.init_id.value;
	if(strID.length < eval(document.form_.init_id_len.value))
		document.form_.new_uid.value = document.form_.init_id.value;
	for(i = 0; i < eval(strInitID.length); ++i) {
		if(strID.charAt(i) == strInitID.charAt(i))
			continue;
		document.form_.new_uid.value = document.form_.init_id.value;
		return;
	}
		
}
</script>
<body bgcolor="#<%=strBGCol%>">
<form name="form_" action="./chng_loginid_pwd.jsp" method="post">
<%@ page language="java" import="utility.*" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strEmpID = null;
	String strTemp  = null;
	WebInterface WI = new WebInterface(request);
	boolean bolChangePassword = false;
	
	if(request.getParameter("changePassword") != null && request.getParameter("changePassword").compareTo("1") ==0 && 
		request.getSession(false).getAttribute("userId_") != null) 
		bolChangePassword = true;

	try
	{
		//if(bolChangePassword)
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
strEmpID = (String)request.getSession(false).getAttribute("userId_");
if(strEmpID == null || strEmpID.trim().length() == 0) {
	strErrMsg = "Please login to change login ID and Password.";
}
else if(bolChangePassword){ //update password 
	PasswordManagement PM = new PasswordManagement();
	if(! PM.changeUserIDAndPwd(dbOP, request) )
		strErrMsg = PM.getErrMsg();
}

boolean bolIsPasswordComplex = false;
strTemp = "select prop_val from read_Property_file where prop_name = 'FORCE_COMPLEX_PASSWORD' and prop_val = '1'";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null)
	bolIsPasswordComplex = true;
	

if(dbOP != null)
	dbOP.cleanUP();
	

String strInitID = (String)request.getSession(false).getAttribute("init_id");
if(strInitID == null) 
	strInitID = "";

%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#<%=strHeaderCol%>"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CHANGE LOGIN ID AND PASSWORD ::::</strong></font></div></td>
    </tr>
</table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><p><br>
        </p></td>
      <td height="25" colspan="3"><p><font size="3"><strong>
	  <%if(strErrMsg == null) {%>
	  You are logging in 
          for the first time. Please change your Login ID and password. </strong></font></p>
        <font size="3"> <u>Rules to change login ID and password</u><br>
        1. Length of login ID must be more than 4 characters and less than 26 characters<br>
        2. Password must not be same as Login ID or Employee ID<br>
		3. Login ID and password must not contain ' and "<br>
		<%if(bolIsPasswordComplex) {%>
		4. Length of password must be more than 7 characters and less than 30 characters<br>
		5. Password must contain digits 0 to 9 <br>
		6. Password must contain characters a to z or A to Z<br>
		7. Password must contain special characters. Allowed special characters are <br>
			&nbsp;&nbsp;&nbsp;&nbsp; ~ ! @ # $ % ^ & * ( ) - _ = + { [ } ] ; : | \ < , > . ? /
		<%}else{%>
		4. Length of password must be more than 4 characters and less than 26 characters<br>
		<%}%>
		
	<%}%>	</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp; </td>
    </tr>
    <%
if(strErrMsg != null)
{%>
    <tr> 
      <td height="25" colspan="4">&nbsp; <font size="4"><%=strErrMsg%></font></td>
    </tr>
    <%return;}%>
    <tr> 
      <td width="12%" height="37">&nbsp;</td>
      <td width="17%">New Login ID</td>
      <td width="71%" colspan="2">
<%
strTemp = WI.fillTextValue("new_uid");
if(strTemp.length() == 0 || strTemp.length() < strInitID.length() ) 
	strTemp = strInitID;
%>
	  <input name="new_uid" type="text" size="32" maxlength="30" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:17px"
	  value="<%=strTemp%>" onKeyUp="CheckInitID();"><font size="1"><%=WI.getStrValue(strInitID," ID must start with :::<b> ","</b>","")%></font></td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td>New Password</td>
      <td colspan="2"><input name="new_pwd" type="password" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:17px"></td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td>Retype Password</td>
      <td colspan="2"><input name="retype" type="password" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:17px"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><input type="image" src="../images/save.gif" width="48" height="28" onClick="ChangePassword();"> 
        <font size="1">click to save new password</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong><font size="3"> 
        <%
if(bolChangePassword && strErrMsg == null)
{%>
        Login ID and Password successfully changed. <a href="../" target="_parent">Click here to login</a> 
        <%}%>
        </font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#<%=strHeaderCol%>"> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="bgcol" value="<%=strBGCol%>">
  <input type="hidden" name="headercol" value="<%=strHeaderCol%>">
<input type="hidden" name="changePassword" value="0">

<input type="hidden" name="init_id" value="<%=strInitID%>">
<input type="hidden" name="init_id_len" value="<%=strInitID.length()%>">
</form>
</body>
</html>
