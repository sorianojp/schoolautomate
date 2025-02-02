<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
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
<title>AC Team Manangement</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function UpdateTeamMembers(strTeamIndex){
		var pgLoc = "./ac_team_members.jsp?team_index="+strTeamIndex;	
		var win=window.open(pgLoc,"UpdateTeamMembers",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this team?'))
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
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function RefreshPage() {
		document.form_.prepareToEdit.value='';
		document.form_.team_name.value = "";
		document.form_.team_note.value = "";
		document.form_.team_code.value = "";
		document.form_.submit();
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","ac_team_mgmt.jsp");
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

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	String strSQLQuery = "update ac_tun_team_member set is_valid = 0, last_mod_by = 0 where MEMBER_INDEX in "+
						"(select user_index from user_Table where EXPIRE_DATE <='"+WI.getTodaysDate()+"')";
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(billTsu.operateOnTeams(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = billTsu.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Team information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Team information successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Team information successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = billTsu.operateOnTeams(dbOP, request, 4);

	if(strPrepareToEdit.equals("1")){
		vEditInfo = billTsu.operateOnTeams(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = billTsu.getErrMsg();
	}
	
%>
<body bgcolor="#D2AE72" onload="document.form_.team_name.focus();">
<form name="form_" action="./ac_team_mgmt.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: TEAM MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Team Name: </td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("team_name");
				%>
				<input type="text" name="team_name" value="<%=strTemp%>" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					size="32" maxlength="128"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Team Code: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("team_code");
				%>
				<input type="text" name="team_code" value="<%=strTemp%>" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					size="15" maxlength="12"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Note: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
					else
						strTemp = WI.fillTextValue("team_note");
				%>
				<textarea name="team_note" style="font-size:12px" cols="40" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		  	<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save team information.</font>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
							<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit team information.</font>
					<%}
				}%>
			  <a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
			  <font size="1">Click to refresh page.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: TEAM LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Team Name</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Team Code </strong></td>
			<td width="23%" align="center" class="thinborder"><strong>Team Note</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Members</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=5, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:UpdateTeamMembers('<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/update.gif" border="0" /></a>
					
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}else{%>
					Not authorized.
				<%}%></td>
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
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>