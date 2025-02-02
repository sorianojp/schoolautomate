<%@ page language="java" import="utility.*,cashcard.TerminalManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Terminal IP Management Page</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this terminal IP?'))
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
	
	function RefreshPage(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	
	//add security here.
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-TERMINAL MANAGEMENT"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Terminal Management","terminal_ip_management.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	
	TerminalManagement tm = new TerminalManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(tm.operateOnTerminalIP(dbOP, request, Integer.parseInt(strTemp)) == null )
			strErrMsg = tm.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Terminal IP successfully removed.";
			else if(strTemp.equals("1"))
				strErrMsg = "Terminal IP successfully added.";
			else if(strTemp.equals("2"))
				strErrMsg = "Terminal IP successfully edited.";
				
			strPrepareToEdit = "0";
		}
	}
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = tm.operateOnTerminalIP(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = tm.getErrMsg();
	}
	
	if(WI.fillTextValue("dept_name").length() > 0){
		vRetResult = tm.operateOnTerminalIP(dbOP, request, 4);
		if (vRetResult == null && strTemp.length() == 0)
			strErrMsg = tm.getErrMsg();
	}
%>		
<body bgcolor="#D2AE72">
<form name="form_" action="./terminal_ip_management.jsp" method="post">

	<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" align="center"><font color="#FFFFFF"><strong>:::: TERMINAL IP MANAGEMENT PAGE ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%"></td>
			<td width="17%">Department Name:</td>
			<td width="80%">
				<%if(vEditInfo != null && vEditInfo.size() > 0){%>
					<input type="hidden" name="dept_name" value="<%=(String)vEditInfo.elementAt(2)%>" />
					<strong><%=(String)vEditInfo.elementAt(3)%></strong>
				<%}else{
					strTemp = WI.fillTextValue("dept_name");
				%>
				<select name="dept_name" onchange="RefreshPage();">
					<option value="">Select Department</option>
					<%=dbOP.loadCombo("terminal_dept_index","dept_name"," from cc_terminal_dept where is_valid = 1 order by dept_name",strTemp, false)%>
				</select>
				<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>IP Address :</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0) 
						strTemp = (String)vEditInfo.elementAt(1);
					else	
						strTemp = WI.fillTextValue("ip_addr");
				%>
				<input type="text" name="ip_addr" value="<%=strTemp%>" class="textbox" size="16" maxlength="15"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2"></td>
			<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save IP information.</font>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit IP information.</font>
					    <%}
				}%>
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
			<font size="1">Click to refresh page.</font></td>	
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr> 
	</table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="3" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF TERMINAL IP ADDRESS ::: </strong></div></td>
		</tr>
		<tr> 
			<td height="25" width="55%" align="center" class="thinborder"><strong>Department Name</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>IP Address</strong></td> 
			<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 4){%>
		<tr> 
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
			<td class="thinborder" align="center">
			<%if(iAccessLevel > 1){%>
			<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
			<%}if(iAccessLevel == 2) {%>
			<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
			<%}%>	  </td>
		</tr>
	<%}%>
	</table>
<%}//end of vRetResult%>

	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
		<tr bgcolor="#FFFFFF">
			<td height="25">&nbsp;</td>
		</tr> 
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>