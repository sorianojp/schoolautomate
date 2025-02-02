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
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex)
{
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function CollapsePage(strAction)
{
	document.form_.collapse_fields.value = strAction;
	document.form_.submit();
}
</script>
<body bgcolor="#<%=strBGCol%>">
<form name="form_" action="./change_password.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.ParentRegistration,java.util.Vector" %>
<%
 //only used to load the Course offered, degree, year offered, semester offered and curriculum year (School year)
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strEmpID = null;
	
	WebInterface WI = new WebInterface(request);
	

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PARENT REGISTRATION"),"0"));		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security
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
	
String strInfoIndex = WI.fillTextValue("info_index");
strInfoIndex = "1";
ParentRegistration prSMS = new ParentRegistration();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(!prSMS.operateOnChangePassword(dbOP, request, Integer.parseInt(strTemp)))
		strErrMsg = prSMS.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Password successfully changed.";
		else
			strErrMsg = "Login ID successfully changed.";
	}
}

%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<tr><td height="25" bgcolor="#<%=strHeaderCol%>"><div align="center"><font color="#FFFFFF" ><strong>:::: CHANGE PASSWORD ::::</strong></font></div></td></tr>
<tr><td height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td></tr>
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td align="right">
		<input type="button" name="add" value="Change Password" onClick="javascript:CollapsePage('1');"
						style="font-size:11px; height:28px;border: 1px solid #FF0000; width:10%;" />
		</td>
	</tr>
	<tr><td >&nbsp;</td></tr>
	<tr>
		<td align="right">
		<input type="button" name="add" value="Change Login ID" onClick="javascript:CollapsePage('2');"
						style="font-size:11px; height:28px;border: 1px solid #FF0000; width:10%;" />
		</td>
	</tr>
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	
	<%if(WI.fillTextValue("collapse_fields").length() > 0){
		if(WI.fillTextValue("collapse_fields").equals("1")){
	%>
	<tr> 
      <td width="24%" height="25">&nbsp;</td>
      <td width="18%">Old Password</td>
      <td width="58%" colspan="2"><input name="password"  value="<%=WI.fillTextValue("password")%>" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>New Password</td>
      <td colspan="2"><input name="new_password"  value="<%=WI.fillTextValue("new_password")%>" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Retype Password</td>
      <td colspan="2"><input name="confirm_new_password"  value="<%=WI.fillTextValue("confirm_new_password")%>" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	<%}else{%>
	
	
	<tr> 
      <td width="24%" height="25">&nbsp;</td>
      <td width="18%">Old Login ID</td>
      <td width="58%" colspan="2"><input name="login_id" size="32" maxlength="32" class="textbox" value="<%=WI.fillTextValue("login_id")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>New Login ID</td>
      <td colspan="2"><input name="new_login_id"  value="<%=WI.fillTextValue("new_login_id")%>" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Retype Login ID</td>
      <td colspan="2"><input name="confirm_new_login_id"  value="<%=WI.fillTextValue("confirm_new_login_id")%>" size="32" maxlength="32" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	
	
	<%}%>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><input type="image" src="../../images/save.gif" width="48" height="28" onClick="PageAction('<%=WI.fillTextValue("collapse_fields")%>','<%=strInfoIndex%>');"><font size="1">click 
        to save new password</font></td>
    </tr>
	<%}%>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<tr><td height="25">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#<%=strHeaderCol%>">&nbsp;</td></tr>
</table>
<input type="hidden" name="headercol" value="<%=strHeaderCol%>">



<input type="hidden" name="goback" value="<%=WI.fillTextValue("goback")%>">

<input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" >
<input type="hidden" name="collapse_fields" value="<%=WI.fillTextValue("collapse_fields")%>" >
</form>
</body>
</html>
