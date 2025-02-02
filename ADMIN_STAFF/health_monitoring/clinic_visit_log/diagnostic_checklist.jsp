<%@ page language="java" import="utility.*, health.AUFHealthProgram, java.util.Vector " %>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Accredited Physician Mgmt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function PrintPage(){
		document.form_.print_page.value = "1";
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.save_checklist.value = "";
		document.form_.submit();
	}

	function SaveChecklist(){
		document.form_.print_page.value = "";
		document.form_.save_checklist.value = "1";
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.submit();
	}
	
	function ReloadParentWnd() {	
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
	
</script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./print_slip_diagnostic.jsp" />
	<% 
		return;}

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","diagnostic_checklist.jsp");
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
															"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
															"diagnostic_checklist.jsp");
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
	
	String strVisitLogIndex = WI.fillTextValue("visit_log_index");
	String strPhysician = null;
	
	AUFHealthProgram hp = new AUFHealthProgram();
	
	if(WI.fillTextValue("save_checklist").length() > 0){
		if(!hp.saveDiagnosticChecklist(dbOP, request))
			strErrMsg = hp.getErrMsg();
		else
			strErrMsg = "Diagnostic checklist successfully saved.";
	}
	
	Vector vRetResult = hp.getDiagnosticChecklist(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hp.getErrMsg();
%>
<body bgcolor="#8C9AAA" class="bgDynamic" onUnload="ReloadParentWnd();">
<form action="./diagnostic_checklist.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F"> 
			<td height="25" class="footerDynamic"><div align="center"><font color="#FFFFFF">
				<strong>:::: DIAGNOSTIC CHECKLIST PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;<strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){
	int iCount = 0;
	int iTestCount = 0;
	String strGroupName = null;
	String strGroupIndex = null;
	Vector vTests = null;
%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  	<td height="25" colspan="4">&nbsp;Physician: 
				<%
					strTemp = " from hm_accredited_physicians where is_valid = 1 order by physician_name ";
					strPhysician = (String)vRetResult.remove(0);
					strErrMsg = WI.getStrValue(strPhysician, WI.fillTextValue("physician"));					
				%>
				<select name="physician">
					<option value="">Select Physician</option>
					<%=dbOP.loadCombo("physician_index","physician_name", strTemp, strErrMsg, false)%>
				</select></td>
	  	</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="25%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
				<%while(iCount < 3 && vRetResult.size() > 0){
					strGroupIndex = (String)vRetResult.remove(0);
					strGroupName = (String)vRetResult.remove(0);
					vTests = (Vector)vRetResult.remove(0);
					iCount++;
				%>	
					<tr>
						<td height="20">&nbsp;<u><strong><%=strGroupName%></strong></u></td>
					</tr>
					<%for(int j = 0; j < vTests.size(); j += 3, iTestCount++){%>
					<tr>
						<td height="25">
							<%
								strTemp = (String)vTests.elementAt(j+2);
								if(strTemp.equals("1"))
									strTemp = "checked";
								else
									strTemp = "";
							%>
							&nbsp;<input type="checkbox" name="test_<%=iTestCount%>" value="<%=(String)vTests.elementAt(j)%>" <%=strTemp%>>&nbsp;
								<%=(String)vTests.elementAt(j+1)%></td>
					</tr>
					<%}%>
				<%}%>
				</table>			</td>
		    <td width="25%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
				<%if(vRetResult.size() > 0){
					strGroupIndex = (String)vRetResult.remove(0);
					strGroupName = (String)vRetResult.remove(0);
					vTests = (Vector)vRetResult.remove(0);
					iCount++;
				%>	
					<tr>
						<td height="25"><u><strong><%=strGroupName%></strong></u></td>
					</tr>
					<%for(int j = 0; j < vTests.size(); j += 3, iTestCount++){%>
					<tr>
						<td height="20">
							<%
								strTemp = (String)vTests.elementAt(j+2);
								if(strTemp.equals("1"))
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="checkbox" name="test_<%=iTestCount%>" value="<%=(String)vTests.elementAt(j)%>" <%=strTemp%>>&nbsp;
								<%=(String)vTests.elementAt(j+1)%></td>
					</tr>
					<%}%>
				<%}%>
				</table>			</td>
		    <td width="25%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
				<%if(vRetResult.size() > 0){
					strGroupIndex = (String)vRetResult.remove(0);
					strGroupName = (String)vRetResult.remove(0);
					vTests = (Vector)vRetResult.remove(0);
					iCount++;
				%>	
					<tr>
						<td height="25"><u><strong><%=strGroupName%></strong></u></td>
					</tr>
					<%for(int j = 0; j < vTests.size(); j += 3, iTestCount++){%>
					<tr>
						<td height="20">
							<%
								strTemp = (String)vTests.elementAt(j+2);
								if(strTemp.equals("1"))
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="checkbox" name="test_<%=iTestCount%>" value="<%=(String)vTests.elementAt(j)%>" <%=strTemp%>>&nbsp;
								<%=(String)vTests.elementAt(j+1)%></td>
					</tr>
					<%}%>
				<%}%>
				</table>			</td>
		    <td width="25%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
				<%while(vRetResult.size() > 0){
					strGroupIndex = (String)vRetResult.remove(0);
					strGroupName = (String)vRetResult.remove(0);
					vTests = (Vector)vRetResult.remove(0);
					iCount++;
				%>	
					<tr>
						<td height="20"><u><strong><%=strGroupName%></strong></u></td>
					</tr>
					<%for(int j = 0; j < vTests.size(); j += 3, iTestCount++){%>
					<tr>
						<td height="25">
							<%
								strTemp = (String)vTests.elementAt(j+2);
								if(strTemp.equals("1"))
									strTemp = "checked";
								else
									strTemp = "";
							%>
							<input type="checkbox" name="test_<%=iTestCount%>" value="<%=(String)vTests.elementAt(j)%>" <%=strTemp%>>&nbsp;
								<%=(String)vTests.elementAt(j+1)%></td>
					</tr>
					<%}%>
				<%}%>
				</table>			</td>
			<input type="hidden" name="test_count" value="<%=iTestCount%>">
		</tr>	
		<tr>
			<td height="40" colspan="4" align="center">
				<%if(iAccessLevel > 1){			  
					if(strPhysician == null){%>
						<a href="javascript:SaveChecklist();"><img src="../../../images/save.gif" border="0"></a>				
					<%}else{%>
						<a href="javascript:SaveChecklist();"><img src="../../../images/edit.gif" border="0"></a>
					<%}%>
					<font size="1">Click to save diagnostic checklist information.</font>
					<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
					<font size="1">Click to print diagnostic checklist.</font>
				<%}else{%>
					Not authorized to save diagnostic checklist information.
				<%}%></td>
		</tr>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page">
	<input type="hidden" name="save_checklist">
	<input type="hidden" name="visit_log_index" value="<%=strVisitLogIndex%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>