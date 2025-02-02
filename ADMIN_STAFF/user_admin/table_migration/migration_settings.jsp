<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Add Comments</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function DisableTable(strInfoIndex){
		document.form_.page_action.value = "0";		
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function EditSetting(strInfoIndex){
		document.form_.page_action.value = "1";
		document.form_.submit();
	}
	
	function CancelOperation(){
		location = "./migration_settings.jsp";
	}
	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"System Administration-Table Migration","table_migration.jsp");
	}
	catch(Exception exp) {
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
															"System Administration","SET PARAMETERS",request.getRemoteAddr(),
															"table_migration.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo = null;
	Vector vRetResult = null;
	TableMigration tm = new TableMigration();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(tm.operateOnMigrationSettings(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = tm.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Migration setting successfully disabled.";
			if(strTemp.equals("1"))
				strErrMsg = "Migration setting successfully edited.";
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = tm.operateOnMigrationSettings(dbOP, request, 4);
	//if(vRetResult == null)
		//strErrMsg = tm.getErrMsg();
		
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = tm.operateOnMigrationSettings(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = tm.getErrMsg();		
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="migration_settings.jsp">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" align="center" class="footerDynamic" colspan="2">
				<font color="#FFFFFF" ><strong>:::: MIGRATION SETTINGS ::::</strong></font></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
<%if(vEditInfo != null && vEditInfo.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">DB Schema: </td>
			<td width="80%">
				<%
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(0), WI.fillTextValue("db_schema"));
				%>
				<input type="text" name="db_schema" value="<%=strTemp%>" class="textbox"  maxlength="32" size="32"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Table Name: </td>
			<td><%=(String)vRetResult.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		  	<td>Index Name: </td>
		  	<td><%=(String)vRetResult.elementAt(2)%></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
			<td>Field Name: </td>
		  	<td><%=(String)vRetResult.elementAt(3)%></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Display Name: </td>
		  	<td>
				<%
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(4), WI.fillTextValue("display_name"));
				%>
				<input type="text" name="display_name" value="<%=strTemp%>" class="textbox"  maxlength="32" size="32"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
			<td height="25">&nbsp;</td>
		  	<td>Months To Keep: </td>
		  	<td>
				<%
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(5), WI.fillTextValue("months_to_keep"));
				%>
				<input type="text" name="months_to_keep" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','months_to_keep');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyInteger('form_','months_to_keep')" size="5" maxlength="3" /></td>
	  	</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		    <td height="40">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:EditSetting('<%=(String)vEditInfo.elementAt(1)%>');"><img src="../../../images/edit.gif" border="0"></a>
					<font size="1">Click to edit migration settings.</font>
					&nbsp;
					<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
					<font size="1">Click to refresh page.</font>
				<%}else{%>
					Not authorized to change migration settings.
				<%}%></td>
		</tr>
	</table>
<%}
	
if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" bgcolor="#B9B292" class="thinborder" colspan="7">
				<div align="center"><strong>::: MIGRATION SETTINGS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="15%"><strong>DB Schema</strong></td>
	        <td align="center" class="thinborder" width="15%"><strong>Table Name</strong></td>
	        <td align="center" class="thinborder" width="15%"><strong>Index Name</strong></td>
	        <td align="center" class="thinborder" width="15%"><strong>Field Name</strong></td>
	        <td align="center" class="thinborder" width="15%"><strong>Display Name</strong></td>
	        <td align="center" class="thinborder" width="10%"><strong>Months to Keep</strong></td>
			<td align="center" class="thinborder" width="15%"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 6){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i))%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i+1)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if((String)vRetResult.elementAt(i) != null){%>
						<a href="javascript:DisableTable('<%=(String)vRetResult.elementAt(i+1)%>');">
							<img src="../../../images/disable.gif" border="0"></a>
					<%}
				}else{%>
					N/A
				<%}%></td>
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
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
