<%@ page language="java" import="utility.*,osaGuidance.StudentPersonalDataCIT,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Siblings</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
	//called for add or edit and delete.
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
	
	function PageAction(strAction, strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this sibling?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function RefreshPage() {
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.prepareToEdit.value="";
		document.form_.name.value = "";
		document.form_.dob.value = "";
		document.form_.occupation.value = "";
		document.form_.company.value = "";	
		document.form_.page_action.value = "";
		document.form_.submit();
	}
</script>
<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;

	//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT PERSONAL DATA-Student Personal Data","update_sibling.jsp");
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
															"Registrar Management","STUDENT PERSONAL DATA",request.getRemoteAddr(),
															null);
																
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strUserIndex = WI.fillTextValue("user_index");
	if(strUserIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Student reference is not found. Please close this window and click update link again from main window.</p>
		<%return;
	}
	
	Vector vRetResult = null;
	StudentPersonalDataCIT spd = new StudentPersonalDataCIT();
	
	strTemp = WI.fillTextValue("page_action");	
	if(strTemp.length() > 0) {
		if(spd.operateOnSibling(dbOP, request, Integer.parseInt(strTemp), strUserIndex) == null)
			strErrMsg = spd.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Sibling successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Sibling successfully added.";
		}
	}

	vRetResult = spd.operateOnSibling(dbOP, request, 4, strUserIndex);
	if(vRetResult == null && strTemp.length() == 0)
		strErrMsg = spd.getErrMsg();
%>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="form_" action="update_sibling.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: SIBLING MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
		  	<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Name: </td>
		  	<td width="80%">
				<input name="name" type="text" size="32" maxlength="64" value="<%=WI.fillTextValue("name")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Occupation:</td>
			<td>
				<input name="occupation" type="text" size="32" maxlength="64" value="<%=WI.fillTextValue("occupation")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>School/Company:</td>
			<td>
				<input name="company" type="text" size="32" maxlength="64" value="<%=WI.fillTextValue("company")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
	<!--
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date of Birth: </td>
			<td>
				<input name="dob" type="text" size="10" maxlength="10" value="<%=WI.fillTextValue("dob")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
				<a href="javascript:show_calendar('form_.dob',<%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		</tr>
	-->
		<tr>
			<td height="25">&nbsp;</td>
			<td>Age: </td>
			<td>
				<input name="sibling_age" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sibling_age")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sibling_age');style.backgroundColor='white'"
					onKeyUp="AllowOnlyInteger('form_','sibling_age');"></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(iAccessLevel > 1){%>				
					<a href="javascript:PageAction('1', '');"><img src="../../../../images/save.gif" border="0"></a>
						<font size="1">Click to save sibling info.</font>
					<a href="javascript:RefreshPage();"><img src="../../../../images/refresh.gif" border="0"></a>
						<font size="1">Click to refresh page.</font>
				<%}else{%>
					Not authorized to save student sibling information.
				<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="20" colspan="6"><div align="center"><font color="#FFFFFF">
				<strong>:::: LIST OF SIBLINGS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="32%" align="center" class="thinborder"><strong>Name</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Age</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Course/Occupation</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>School/Company</strong></td>
			<td width="8%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 8){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder" align="center">
				<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../../images/delete.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="8" height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="user_index" value="<%=strUserIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>