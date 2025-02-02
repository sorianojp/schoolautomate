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
<title>AC Team Member Mgmt</title>
</head>

<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
			if(this.xmlHttp == null) {
				alert("Failed to init xmlHttp.");
				return;
			}
			
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function PageAction(strAction, strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this team member?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.RefreshPage();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	String strTeamIndex = WI.fillTextValue("team_index");
	if(strTeamIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Team reference is not found. Please close this window and click update link again from main window.</p>
		<%return;
	}
	
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
								"ACCOUNTING-BILLING","ac_team_members.jsp");
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

	
	String strIsTeamLead = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	Vector vTeamInfo = null;
	boolean hasTeamLead = false;
	
	BillingTsuneishi billTsu = new BillingTsuneishi();
	
	vTeamInfo = billTsu.getTeamInformation(dbOP, request, strTeamIndex);
	if(vTeamInfo == null)
		strErrMsg = billTsu.getErrMsg();
	else{
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(billTsu.operateOnTeamMembers(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = billTsu.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "Team member information successfully removed.";
				if(strTemp.equals("1"))
					strErrMsg = "Team member information successfully recorded.";
				if(strTemp.equals("5"))
					strErrMsg = "Team member successfully removed as team lead.";
				if(strTemp.equals("6"))
					strErrMsg = "Team member successfully assigned as team lead.";
				
				strPrepareToEdit = "0";
			}
		}
		
		vRetResult = billTsu.operateOnTeamMembers(dbOP, request, 4);
		
		hasTeamLead = billTsu.hasTeamLead(dbOP, request, strTeamIndex);
	}
%>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="form_" action="./ac_team_members.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: TEAM MEMBERS MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong>Team Information:</strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Team Name: </td>
			<td colspan="2"><%=(String)vTeamInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Note: </td>
			<td colspan="2"><%=WI.getStrValue((String)vTeamInfo.elementAt(2))%></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Member ID: </td>
			<td width="25%">
				<input name="emp_id" type="text" class="textbox" size="16" onKeyUp="AjaxMapName();" 
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("emp_id")%>"
					onBlur="style.backgroundColor='white'"></td>
		    <td width="55%" valign="top"><label id="coa_info" style="position:absolute; width:350px;"></label></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<input name="is_team_lead" type="checkbox" value="1">
				<font size="1">Check if member is team leader.</font></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td colspan="3" style="font-weight:bold; color:#0000FF; font-size:9px;">
				<input name="force_allow" type="checkbox" value="checked" <%=WI.fillTextValue("force_allow")%>> 
					Allow Employee to be team lead of multiple team</td>
	  	</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td colspan="2" valign="middle">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a> 
						<font size="1">click to save team member.</font>
				<%}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: TEAM MEMBER LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="10%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="50%" align="center" class="thinborder"><strong>Member Name </strong><strong></strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Option</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
		<%
			int iCount = 1;
			for(int i = 0; i < vRetResult.size(); i += 4, iCount++){
				strIsTeamLead = (String)vRetResult.elementAt(i+3);
		%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%>
				<%if(strIsTeamLead.equals("1")){%>
					(Team Lead)
				<%}%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){
					if(hasTeamLead){//place only disassign to team lead
						if(strIsTeamLead.equals("1")){%>
							<a href="javascript:PageAction('5', '<%=(String)vRetResult.elementAt(i)%>')">
								<strong><font color="#FF0000"><u>REMOVE AS TEAM LEAD</u></font></strong></a>
						<%}else{%>
							&nbsp;
						<%}				
					}else{//set assign link to all%>
						<a href="javascript:PageAction('6', '<%=(String)vRetResult.elementAt(i)%>')">
							<strong><font color="#FF0000"><u>ASSIGN AS TEAM LEAD</u></font></strong></a>
					<%}%>
				<%}else{%>
					Not authorized.
				<%}%>
			</td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')">
						<img src="../../../images/delete.gif" border="0" /></a>
				<%}else{%>
					Not authorized.
				<%}%>
			</td>
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
	<input type="hidden" name="team_index" value="<%=strTeamIndex%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>