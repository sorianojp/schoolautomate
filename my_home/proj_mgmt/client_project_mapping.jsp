<%@ page language="java" import="utility.*, projMgmt.GTIProject, java.util.Vector" %>
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
<title>Client-Project Mapping</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript">

	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this client-project mapping?'))
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
		location = "./client_project_mapping.jsp";
	}
	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Project Management-Client-Project Mapping","client_project_mapping.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo = null;
	Vector vRetResult = null;

	GTIProject proj = new GTIProject();
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(proj.operateOnClientProjectMapping(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = proj.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Mapping successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Mapping successfully recorded.";
				
			strPrepareToEdit = "0";
		}
	}

	vRetResult = proj.operateOnClientProjectMapping(dbOP, request, 4);
	
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = proj.operateOnClientProjectMapping(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = proj.getErrMsg();		
	}
%>

<body bgcolor="#D2AE72">
<form name="form_" method="post" action="client_project_mapping.jsp">
<br />
<jsp:include page="./tabs.jsp?pgIndex=4"></jsp:include>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Client:</td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("client_index");
				%>
				<select name="client_index">
					<option value="">Select Client</option>
					<%=dbOP.loadCombo("client_index","client_code"," from gti_client where is_valid = 1 "+
									  " order by client_code", strTemp, false)%> 
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("project_index");
				%>
				<select name="project_index">
					<option value="">Select Project</option>
					<%=dbOP.loadCombo("project_index","project_name"," from gti_project where is_valid = 1 "+
									  " order by project_name", strTemp, false)%> 
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project Start Date: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("start_date"); 
				%>
				<input name="start_date" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.start_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Project End Date: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
					else
						strTemp = WI.fillTextValue("end_date"); 
				%>
				<input name="end_date" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.end_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
					<font size="1">Click to save mapping.</font>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit mapping.</font>
					<%}
				}%>
				    
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
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: CLIENT-PROJECT MAPPING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Client </strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Project</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Start Date</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>End Date</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 7, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "-to date-")%></td>
			<td align="center" class="thinborder">
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/edit.gif" border="0"></a>
				<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/delete.gif" border="0"></a>
				</td>
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
