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
<title>Update Clients</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
		
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this project?'))
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
		document.form_.prepareToEdit.value = "";
		document.form_.client_name.value = "";	
		document.form_.client_code.value = "";
		location = "./update_clients.jsp";
	}
	
	function FocusField(){
		document.form_.client_name.focus();
	}
	
</script>

<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Project Management-Update Clients","update_clients.jsp");
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
	Vector vEditInfo  = null; 
	Vector vRetResult = null;

	GTIProject proj = new GTIProject();
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(proj.operateOnClients(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = proj.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Client successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Client successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Client successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}

	vRetResult = proj.operateOnClients(dbOP, request,4);	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = proj.operateOnClients(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = proj.getErrMsg();		
	}
%>

<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" method="post" action="update_clients.jsp">
<br />
<jsp:include page="./tabs.jsp?pgIndex=2"></jsp:include>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Client Name: </td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);			
					else
						strTemp = WI.fillTextValue("client_name");
				%>
				<input type="text" name="client_name" value="<%=strTemp%>" class="textbox" maxlength="128" size="64"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Client Code: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);			
					else
						strTemp = WI.fillTextValue("client_code");
				%>
				<input type="text" name="client_code" value="<%=strTemp%>" class="textbox" maxlength="24"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
					<font size="1">Click to save client.</font>
				    <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit client.</font>
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
		  	<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF CLIENTS CREATED ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="55%" align="center" class="thinborder"><strong>Client Name</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Client Code </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 3, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/edit.gif" border="0"></a>
				<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
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
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
