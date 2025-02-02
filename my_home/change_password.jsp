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
</head>
<script language="JavaScript">
function ChangePassword()
{
	document.chngpassword.changePassword.value = 1;
}
</script>
<body bgcolor="#<%=strBGCol%>">
<form name="chngpassword" action="./change_password.jsp" method="post">
<%@ page language="java" import="utility.*" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strEmpID = null;
	boolean bolChangePassword = false;
	WebInterface WI = new WebInterface(request);
	
	if(request.getParameter("changePassword") != null && request.getParameter("changePassword").compareTo("1") ==0)
		bolChangePassword = true;

	try
	{
		//if(bolChangePassword)
			dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"My Home/ change password","change_password.jsp");
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
strEmpID = (String)request.getSession(false).getAttribute("userId");
if(strEmpID == null || strEmpID.trim().length() == 0)
{
	strErrMsg = "Please login to change password.";
}
else if(bolChangePassword) //update password
{
	String strPassword = request.getParameter("new_password");
	String strRetypePassword = request.getParameter("retype_password");
	if(strRetypePassword == null) strRetypePassword = "";
	if(strPassword != null && strPassword.compareTo(strRetypePassword) == 0)//update password now.
	{
		PasswordManagement PM = new PasswordManagement();
		if(! PM.changePassword(dbOP,request.getParameter("old_password"), request.getParameter("new_password"),strEmpID, 
                                  request.getParameter("forgot_pass_ques"), request.getParameter("forgot_pass_ans"),false,(String)request.getSession(false).getAttribute("login_log_index")) )
		{
			strErrMsg = PM.getErrMsg();
		}
		else
			strErrMsg = "Password successfully changed";
	}
	else
		strErrMsg = "Password and Retype password does not match.";	
}

boolean bolIsPasswordComplex = false;
String strTemp = "select prop_val from read_Property_file where prop_name = 'FORCE_COMPLEX_PASSWORD' and prop_val = '1'";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null)
	bolIsPasswordComplex = true;


if(dbOP != null)
	dbOP.cleanUP();

String strDepth = request.getParameter("back_depth");
if(strDepth == null)
	strDepth = "0";
int iDepth = Integer.parseInt(strDepth);
++iDepth;//history back depth.. 

%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#<%=strHeaderCol%>"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CHANGE PASSWORD ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">
        <font size="3"> <u>Rules to change Password</u><br>
		<%if(bolIsPasswordComplex) {%>
		1. Length of password must be more than 7 characters and less than 30 characters<br>
		2. Password must contain digits 0 to 9 <br>
		3. Password must contain characters a to z or A to Z<br>
		4. Password must contain special characters. Allowed special characters are <br>
			&nbsp;&nbsp;&nbsp;&nbsp; ~ ! @ # $ % ^ & * ( ) - _ = + { [ } ] ; : | \ < , > . ? /
		<%}else{%>
		1. Length of password must be more than 4 characters and less than 26 characters<br>
		2. Password should not be same as Login ID or Employee ID
		<%}%>
		</font></td>
	  
    </tr>
<tr> 
      <td height="25" colspan="4">&nbsp; <font size="3">
	  <%=WI.getStrValue(strErrMsg)%> &nbsp;&nbsp;
<%if(WI.fillTextValue("goback").length() > 0) {%>
	  <a href="javascript:window.history.go(-<%=iDepth%>)">Click to go back</a>
<%}%>
	  </font></td>
    </tr>
    <tr> 
      <td width="24%" height="25">&nbsp;</td>
      <td width="18%">Old Password</td>
      <td width="58%" colspan="2"><input name="old_password" type="password" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>New Password</td>
      <td colspan="2"><input name="new_password" type="password" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Retype Password</td>
      <td colspan="2"><input name="retype_password" type="password" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Forget Password?</td>
      <td colspan="2"><select name="forgot_pass_ques">
          <option value="1" selected>What is your pet name</option>
          <option value="2">What is your favourite color</option>
          <option value="3">What is your mother's maiden name</option>
          <option value="4">What is your best friends name</option>
          <option value="5">What is your favourite Flower</option>
          <option value="6">What is your food</option>
          <option value="7">Keep an arbitray answer.</option>
        </select></td>
    </tr><tr> 
      <td height="25">&nbsp;</td>
      <td><em>Hint Question.</em></td>
      <td colspan="2" valign="top"><font size="1">(optional) - used if you forget your password. 
        </font></td>
    </tr><tr> 
      <td height="25">&nbsp;</td>
      <td>Hint Question Answer</td>
      <td colspan="2"><input type="text" name="forgot_pass_ans" maxlength="64" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(optional) </font></td>
    </tr>
	<tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><input type="image" src="../images/save.gif" width="48" height="28" onClick="ChangePassword();"><font size="1">click 
        to save new password</font></td>
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

<input type="hidden" name="back_depth" value="<%=iDepth%>">
<input type="hidden" name="goback" value="<%=WI.fillTextValue("goback")%>">
</form>
</body>
</html>
