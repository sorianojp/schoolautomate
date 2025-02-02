<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
		
	String strChecklistIndex = WI.fillTextValue("checklist_index");
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Exit Interview Checklist</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/td.js"></script>
<script language="javascript">

	function UpdateChecklist(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.update_checklist.value = "1";
		document.form_.submit();
	}
	
	//called for add or edit and delete.
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	
	boolean bolTemp = false;
	String strFields = null;
	
	if(strChecklistIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Resignation reference is not found. Please close this window and click update link again.</p>
		<%return;
	}

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-EXIT INTERVIEW MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"my_home","update_exit_intv_main.jsp");
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
	
	Vector vRetResult = null;	
	HRLighthouse hrl = new HRLighthouse();
	
	if(WI.fillTextValue("update_checklist").length() > 0){
		if(hrl.operateOnExitIntvChecklist(dbOP, request, 2) == null)
			strErrMsg = hrl.getErrMsg();
		else{
			strErrMsg = "Checklist successfully updated.";
			if(hrl.isChecklistComplete(dbOP, request, strChecklistIndex))
				strErrMsg = "Checklist successfully completed.";
		}
	}
	
	vRetResult = hrl.operateOnExitIntvChecklist(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = hrl.getErrMsg();
	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onUnload="ReloadParentWnd();">
<form name="form_" action="./update_exit_intv_checklist.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" align="center" bgcolor="#A49A6A" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: CLEARANCE FORM: EMPLOYEE LEAVING CHECKLIST ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25" width="5%">&nbsp;</td>
	        <td width="95%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="20%">Employee Name: </td>
			<td width="75%"><%=(String)vRetResult.elementAt(0)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department:</td>
			<td><%=(String)vRetResult.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Exit Date: </td>
			<td><%=(String)vRetResult.elementAt(2)%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" width="20%" align="center" class="thinborder"><strong>Responsibility</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Activity Item</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Comments</strong></td>
		</tr>
		<%
			strFields = "";
			bolTemp = hrl.isOnNotifyList(dbOP, strUserIndex, 1);
			if(bolTemp)
				strErrMsg = "#FFFFFF";
			else{
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
			
			if(hrl.isChecklistComplete(dbOP, request, strChecklistIndex)){
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
		%>
		<tr bgcolor="<%=strErrMsg%>">
			<td rowspan="2" valign="top" class="thinborder">System Admin</td>
			<td class="thinborder" height="25">
				<%
				strTemp = (String)vRetResult.elementAt(3);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="sys_adm1" value="<%=(String)vRetResult.elementAt(3)%>">
					<input name="temp1" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Cancel Email Access
				<%}else{%>
					<input name="sys_adm1" type="checkbox" onClick="javascript:UpdateChecklist()"
						value="1" <%=strTemp%> <%=strFields%>>Cancel Email Access
				<%}%></td>
			<td class="thinborder" rowspan="2" align="center">
				<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="sys_adm_comment" value="<%=strTemp%>">
					<textarea name="temp2" style="font-size:12px" cols="37" rows="2" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white';"><%=strTemp%></textarea>
				<%}else{%>
					<textarea name="sys_adm_comment" style="font-size:12px" cols="37" rows="2" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white';UpdateChecklist()"><%=strTemp%></textarea>
				<%}%></td>
		</tr>
		<tr bgcolor="<%=strErrMsg%>">
			<td height="25" class="thinborder">
				<%
				strTemp = (String)vRetResult.elementAt(4);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
						
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="sys_adm2" value="<%=(String)vRetResult.elementAt(4)%>">
					<input name="temp3" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Cancel Server Access
				<%}else{%>
					<input name="sys_adm2" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Cancel Server Access
				<%}%></td>
		</tr>
		
		<!------------------------------------------->
		<%
			strFields = "";
			bolTemp = hrl.isOnNotifyList(dbOP, strUserIndex, 2);
			if(bolTemp)
				strErrMsg = "#FFFFFF";
			else{
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
			
			if(hrl.isChecklistComplete(dbOP, request, strChecklistIndex)){
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
		%>
		<tr bgcolor="<%=strErrMsg%>">
			<td rowspan="3" valign="top" class="thinborder">Human Resources</td>
			<td class="thinborder" height="25">
				<%
				strTemp = (String)vRetResult.elementAt(6);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
					
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="hr1" value="<%=(String)vRetResult.elementAt(6)%>">
					<input name="temp4" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Resignation Letter
				<%}else{%>
					<input name="hr1" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Resignation Letter
				<%}%></td>
			<td class="thinborder" rowspan="3" align="center">
				<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(9));
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="hr_comment" value="<%=strTemp%>">
					<textarea name="temp5" style="font-size:12px" cols="37" rows="3" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
				<%}else{%>
					<textarea name="hr_comment" style="font-size:12px" cols="37" rows="3" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white';UpdateChecklist()"><%=strTemp%></textarea>
				<%}%></td>
		</tr>
		<tr bgcolor="<%=strErrMsg%>">
			<td height="25" class="thinborder">
				<%
				strTemp = (String)vRetResult.elementAt(7);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="hr2" value="<%=(String)vRetResult.elementAt(7)%>">
					<input name="temp6" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Exit Interview
				<%}else{%>
					<input name="hr2" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Exit Interview
				<%}%></td>
		</tr>
		<tr bgcolor="<%=strErrMsg%>">
			<td height="25" class="thinborder">
				<%
				strTemp = (String)vRetResult.elementAt(8);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="hr3" value="<%=(String)vRetResult.elementAt(8)%>">
					<input name="temp7" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Benefits Cancellation
				<%}else{%>
					<input name="hr3" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Benefits Cancellation
				<%}%></td>
		</tr>
		
		<!------------------------------------------->
		<%
			strFields = "";
			bolTemp = hrl.isOnNotifyList(dbOP, strUserIndex, 3);
			if(bolTemp)
				strErrMsg = "#FFFFFF";
			else{
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
			
			if(hrl.isChecklistComplete(dbOP, request, strChecklistIndex)){
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
		%>
		<tr bgcolor="<%=strErrMsg%>">
			<td height="25" class="thinborder" valign="top">Payroll/Finance</td>
			<td class="thinborder">
				<%
				strTemp = (String)vRetResult.elementAt(10);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="finance1" value="<%=(String)vRetResult.elementAt(10)%>">
					<input name="temp8" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Final Payment/Quitclaim
				<%}else{%>
					<input name="finance1" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Final Payment/Quitclaim
				<%}%></td>
			<td class="thinborder" align="center">
				<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(11));
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="finance_comment" value="<%=strTemp%>">
					<textarea name="temp9" style="font-size:12px" cols="37" rows="1" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
				<%}else{%>
					<textarea name="finance_comment" style="font-size:12px" cols="37" rows="1" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white';UpdateChecklist()"><%=strTemp%></textarea>
				<%}%></td>
		</tr>
		
		<!------------------------------------------->
		<%
			strFields = "";
			bolTemp = hrl.isOnNotifyList(dbOP, strUserIndex, 4);
			if(bolTemp)
				strErrMsg = "#FFFFFF";
			else{
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
			
			if(hrl.isChecklistComplete(dbOP, request, strChecklistIndex)){
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
		%>
		<tr bgcolor="<%=strErrMsg%>">
			<td rowspan="2" valign="top" class="thinborder">Admin/Facilities/Security</td>
			<td class="thinborder" height="25">
				<%
				strTemp = (String)vRetResult.elementAt(12);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="admin1" value="<%=(String)vRetResult.elementAt(12)%>">
					<input name="temp10" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Office Keys 
				<%}else{%>
					<input name="admin1" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Office Keys 
				<%}%></td>
			<td class="thinborder" rowspan="2" align="center">
				<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(14));
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="admin_comment" value="<%=strTemp%>">
					<textarea name="temp11" style="font-size:12px" cols="37" rows="2" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
				<%}else{%>
					<textarea name="admin_comment" style="font-size:12px" cols="37" rows="2" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white';UpdateChecklist()"><%=strTemp%></textarea>
				<%}%></td>
		</tr>
		<tr bgcolor="<%=strErrMsg%>">
			<td height="25" class="thinborder">
				<%
				strTemp = (String)vRetResult.elementAt(13);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="admin2" value="<%=(String)vRetResult.elementAt(13)%>">
					<input name="temp12" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Cancel Server Access
				<%}else{%>
					<input name="admin2" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Cancel Server Access
				<%}%></td>
		</tr>
		
		<!------------------------------------------->
		<%
			strFields = "";
			bolTemp = hrl.isOnNotifyList(dbOP, strUserIndex, 5);
			if(bolTemp)
				strErrMsg = "#FFFFFF";
			else{
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
			
			if(hrl.isChecklistComplete(dbOP, request, strChecklistIndex)){
				strErrMsg = "#CCCCCC";
				strFields = "disabled";
			}
		%>
		<tr bgcolor="<%=strErrMsg%>">
			<td rowspan="3" valign="top" class="thinborder">Manager</td>
			<td class="thinborder" height="25">
				<%
				strTemp = (String)vRetResult.elementAt(15);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
						
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="manager1" value="<%=(String)vRetResult.elementAt(15)%>">
					<input name="temp13" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Computer Unit 
				<%}else{%>
					<input name="manager1" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Computer Unit 
				<%}%></td>
			<td class="thinborder" rowspan="3" align="center">
				<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(18));
				
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="manager_comment" value="<%=strTemp%>">
					<textarea name="temp14" style="font-size:12px" cols="37" rows="3"
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
				<%}else{%>
					<textarea name="manager_comment" style="font-size:12px" cols="37" rows="3"
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" <%=strFields%>
						onBlur="style.backgroundColor='white';UpdateChecklist()"><%=strTemp%></textarea>
				<%}%></td>
		</tr>
		<tr bgcolor="<%=strErrMsg%>">
			<td height="25" class="thinborder">
				<%
				strTemp = (String)vRetResult.elementAt(16);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
						
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="manager2" value="<%=(String)vRetResult.elementAt(16)%>">
					<input name="temp15" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Other equipment issued 
				<%}else{%>
					<input name="manager2" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Other equipment issued 
				<%}%></td>
		</tr>
		<tr bgcolor="<%=strErrMsg%>">
			<td height="25" class="thinborder">
				<%
				strTemp = (String)vRetResult.elementAt(17);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
						
				if(strFields.equals("disabled")){%>
					<input type="hidden" name="manager3" value="<%=(String)vRetResult.elementAt(17)%>">
					<input name="temp16" type="checkbox" value="1" <%=strTemp%> <%=strFields%>>Soft and Hard copies of Documents responsible for,  project data , etc
				<%}else{%>
					<input name="manager3" type="checkbox" value="1" <%=strTemp%> <%=strFields%>
						onclick="javascript:UpdateChecklist()">Soft and Hard copies of Documents responsible for,  project data , etc
				<%}%></td>
		</tr>
	</table>
<%}%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A" class="footerDynamic"> 
			<td width="1%" height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="checklist_index" value="<%=strChecklistIndex%>">
	
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="update_checklist">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>