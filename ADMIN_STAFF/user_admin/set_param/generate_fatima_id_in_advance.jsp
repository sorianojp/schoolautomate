<%@ page language="java" import="utility.*, enrollment.OfflineAdmission, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Lock Credential Access</title></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function generateID() {
	if(document.form_.sy_from.value.length == 0) {
		alert("Please enter sy from value.");
		return;
	}
	if(document.form_.start_fr.value.length == 0) {
		alert("Please enter start from value.");
		return;
	}
	if(document.form_.max_count.value.length == 0) {
		alert("Please enter max count value.");
		return;
	}
	document.form_.submit();
}	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	Vector vRetResult = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameter","generate_fatima_id_in_advance.jsp");

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
															"System Administration","Set Parameters",request.getRemoteAddr(),
															"generate_fatima_id_in_advance.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	//end of authenticaion code.
	if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("start_fr").length() > 0 && WI.fillTextValue("max_count").length() > 0) {
		OfflineAdmission ofA = new OfflineAdmission();
		vRetResult = ofA.generateIDs(dbOP, request);
		if(vRetResult == null)
			ofA.getErrMsg();
	}
	

%>
<body bgcolor="#D2AE72">
<form name="form_" action="./generate_fatima_id_in_advance.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::: GENERATE ID :::</strong></font></div></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td width="17%">SY/Term: </td>
	  	    <td width="80%">
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"))%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Range to Generate </td>
		  	<td><input name="start_fr" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.fillTextValue("start_fr")%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"/>
		  	  to 
	  	      <input name="max_count" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.fillTextValue("max_count")%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
	  	</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		    <td height="25">
				<a href="javascript:generateID();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to generate ID. </font></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="100%" height="15">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: ID LIST:::</strong></div></td>
		</tr>
		<tr>
			<td height="25" class="thinborder" align="center" width="16%"><strong>ID Number </strong></td>
	    </tr>
	<%for(int i = 0; i < vRetResult.size(); ++i){%>
		<tr>
			<td height="25" class="thinborder"><%=vRetResult.elementAt(i)%></td>
	    </tr>
	<%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action" />
	<input type="hidden" name="info_index"/>
	<input type="hidden" name="unblock_reason" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>