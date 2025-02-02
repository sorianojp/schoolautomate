<%@ page language="java" import="utility.*, projMgmt.GTIProjectTodo, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){%>
		<p style="font-size:16px; color:#FF0000;">You are logged out.</p>
		<%return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Finish</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
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
			if(!confirm('Are you sure you want to delete this finish information?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strInfoIndex.length > 0)
			document.form_.todo_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = "";
		document.form_.todo_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function RefreshPage() {
		document.form_.donot_call_close_wnd.value = "1";
		location = "./update_finish.jsp?info_index="+document.form_.info_index.value;
	}
	
</script>

<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	String strInfoIndex = WI.fillTextValue("info_index");
	if(strInfoIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Todo reference is not found. Please close this window and click link again from main window.</p>
		<%return;
	}
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Project Management-Update Finish","update_finish.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	Vector vRetResult = null;

	GTIProjectTodo proj  = new GTIProjectTodo();
	strTemp = WI.fillTextValue("page_action");

	if(strTemp.length() > 0) {
		if(proj.operateOnTodoFinish(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = proj.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Finish information comment successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Finish information comment successfully recorded.";
		}
	}

	vRetResult = proj.operateOnTodoFinish(dbOP, request, 4);

%>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="form_" method="post" action="update_finish.jsp">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" align="center" class="footerDynamic">
				<font color="#FFFFFF"><strong>:::: FINISH INFORMATION PAGE ::::</strong></font></td>
		</tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Date Finished: </td>
		  	<td width="80%">
				<input name="finish_date" type="text" size="16" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("finish_date")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.finish_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../images/calendar_new.gif" border="0"></a>
				&nbsp;&nbsp;&nbsp;
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("hour_of_day"), "1");
				%>
				<select name="hour_of_day">
					<%for(int i = 1; i <= 12; i++){
						if(Integer.parseInt(strTemp) == i)
							strErrMsg = " selected";
						else
							strErrMsg = "";
					%>
					<option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
					<%}%>
				</select> 
				:
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("minute"), "0");
				%>
				<select name="minute">
					<%for(int i = 0; i <= 59; i++){
						if(Integer.parseInt(strTemp) == i)
							strErrMsg = " selected";
						else
							strErrMsg = "";
					%>
					<option value="<%=i%>"<%=strErrMsg%>><%=CommonUtil.formatMinute(Integer.toString(i))%></option>
					<%}%>
				</select>
				&nbsp;
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("am_pm"), "0");
				%>
				<select name="am_pm">
					<%if(strTemp.equals("0")){%>
						<option value="0" selected>AM</option>
					<%}else{%>
						<option value="0">AM</option>
					
					<%}if(strTemp.equals("1")){%>
						<option value="1" selected>PM</option>
					<%}else{%>
						<option value="1">PM</option>
					<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
				<font size="1">Click to save information.</font>
				&nbsp;				    
				<a href="javascript:RefreshPage();"><img src="../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="3" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: PROJECT FINISH INFORMATION ::: </strong></div></td>
		</tr>
		<tr>
			<td width="60%" height="25" align="center" class="thinborder"><strong>Finish Information </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Date Created </strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 2, iCount++){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:PageAction('0', '<%=strInfoIndex%>');">
					<img src="../../images/delete.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
<%}%>	

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="todo_index" value="<%=WI.fillTextValue("todo_index")%>">

	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	
	<!--this is the todo_index from main page-->
	<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>