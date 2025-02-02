<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	TableMigration tm = new TableMigration();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Restore Old Records</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function GetRecordsToRestore(){
		document.form_.get_records.value = "1";
		document.form_.submit();
	}
	
	function RestoreOldRecords(){
		document.form_.move_records.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	DBOperation dbOP2 = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"System Administration-Restore Old Records","return_old_records.jsp");
				
		strTemp = "select db_schema from migration_settings where db_schema is not null and months_to_keep is not null";
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		
		if(strTemp == null){
			strErrMsg = "Migration settings not set";
			throw new Exception();
		}
		dbOP2 = new DBOperation(strTemp);
	}
	catch(Exception exp) {
		if(dbOP != null)
			dbOP.cleanUP();
		if(dbOP2 != null)
			dbOP2.cleanUP();
		if(strErrMsg == null){
			strErrMsg = "Error in Opening Connection";
			exp.printStackTrace();
		}
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=strErrMsg%></font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","SET PARAMETERS",request.getRemoteAddr(),
															"return_old_records.jsp");
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
	
	if(WI.fillTextValue("move_records").length() > 0){
		if(!tm.restoreOldRecords(dbOP, dbOP2, request))
			strErrMsg = tm.getErrMsg();
	}
	
	int iRecords = -1;
	if(WI.fillTextValue("get_records").length() > 0){
		iRecords = tm.getRecordsToRestore(dbOP, dbOP2, request);
		if(iRecords == -1)
			strErrMsg = tm.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="return_old_records.jsp">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" align="center" class="footerDynamic" colspan="3">
				<font color="#FFFFFF"><strong>:::: RESTORE OLD RECORDS ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Records for: </td>
			<td width="80%">
				<select name="records_for">
					<option value=""></option>
					<%=dbOP.loadCombo("table_name","display_name"," from migration_settings where db_schema is not null "+
										" and months_to_keep is not null ", WI.fillTextValue("records_for"), false)%> 
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Date Range: </td>
		    <td>
				<input name="date_fr" type="text" size="16" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a>
				-
				<input name="date_to" type="text" size="16" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td><a href="javascript:GetRecordsToRestore();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to get number of items to be restored.</font></td>
		</tr>
	<%if(iRecords > -1){%>
		<tr>
			<td height="15" colspan="3"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Record Count: </td>
		    <td><strong><%=iRecords%></strong></td>
		</tr>
		<%if(iRecords > 0){//change to 0 later on%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:RestoreOldRecords();"><img src="../../../images/move.gif" border="0"></a>
				<font size="1">Click to restore records.</font></td>
		</tr>
		<%}%>
	<%}%>
	</table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="move_records">
	<input type="hidden" name="get_records">
</form>
</body>
</html>
<%
dbOP2.cleanUP();
dbOP.cleanUP();
%>
