<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SUBJECT SECTION MAINTENANCE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function CopyMiscFeeName()
{
	document.form_.new_fee_name.value = document.form_.fee_name_reference[document.form_.fee_name_reference.selectedIndex].text;
}
function CloseWindow()
{
	document.form_.close_wnd_called.value = "1";
	window.opener.document.oth_miscfee.submit();
	window.opener.focus();
	self.close();
}
function EditRecord() {
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.edit_record.value = "1";
	document.form_.submit();
}
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.oth_miscfee.submit();
		window.opener.focus();
	}
}
</script>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

	boolean bolHandsOn = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-misc fee","fm_misc_fee_update_fee_name.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"fm_misc_fee_update_fee_name.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

FAFeeMaintenance FA = new FAFeeMaintenance();
if(WI.fillTextValue("edit_record").compareTo("1") ==0 && WI.fillTextValue("fee_name_reference").length() > 0 &&
 		WI.fillTextValue("new_fee_name").length() > 0) {
	if(FA.editFeeName(dbOP, WI.fillTextValue("fee_name_reference"),WI.fillTextValue("new_fee_name"),
			(String)request.getSession(false).getAttribute("login_log_index")) )
		strErrMsg = "Fee name changed successfully.";
	else	
		strErrMsg = FA.getErrMsg();
}
%>
<form name="form_" method="post" action="./fm_misc_fee_update_fee_name.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MISCELLANEOUS FEE MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a> 
        <font size="1"><strong>Click to close window</strong></font></td>
    </tr>
<%
if(strErrMsg != null){%>    <tr> 
      <td colspan="5" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Old Fee Name</td>
      <td width="74%" height="25"><select name="fee_name_reference" onChange="CopyMiscFeeName();" >
          <option value="">Select a Fee name</option>
          <%=dbOP.loadCombo("distinct FEE_NAME","fee_name"," from FA_MISC_FEE where IS_DEL=0 and is_valid=1 order by FA_MISC_FEE.fee_name asc", null, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td width="0%" height="25">&nbsp;</td>
      <td width="26%" height="25">New Fee Name</td>
      <td><input name="new_fee_name" type="text" size="45" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="if(event.keyCode==39 || event.keyCode==34) event.returnValue=false;"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td> <%if(iAccessLevel > 1){%>
        <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"> 
        </a> <font size="1">click to save changes</font> 
        <%}else{%>
        Not authorized to edit 
        <%}%> </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- all hidden fields go here -->
<input type="hidden" name="edit_record">
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>