<%@ page language="java" import="utility.*, visitor.VisitLog, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Terminal Mgmt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this terminal info?'))
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
		location = "./visit_terminal_mgmt.jsp";
	}
	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Visitor Management-Terminal Mgmt","visit_terminal_mgmt.jsp");
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
															"Visitor Management","Terminal Mgmt",request.getRemoteAddr(),
															"visit_terminal_mgmt.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	VisitLog visitLog = new VisitLog();
	
	Vector vEditInfo = null;
	Vector vRetResult = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(visitLog.operateOnTerminals(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = visitLog.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Terminal information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Terminal information successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Terminal information successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = visitLog.operateOnTerminals(dbOP, request, 4);
	if(vRetResult == null && strTemp.length() == 0)
		strErrMsg = visitLog.getErrMsg();
		
	if(strPrepareToEdit.equals("1")){
		vEditInfo = visitLog.operateOnTerminals(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = visitLog.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="visit_terminal_mgmt.jsp">
<jsp:include page="./tabs.jsp?pgIndex=3"></jsp:include>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">IP Address:</td>
	        <td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("ip_address");
				%>
				<input name="ip_address" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="32"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Location:</td>
		  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("loc_index");
				%>
				<select name="loc_index">
					<%=dbOP.loadCombo("location_index","loc_name"," from esc_login_loc where is_del = 0 order by loc_name", strTemp, false)%>
				</select></td>
	  	</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
					<font size="1">Click to save entry.</font>
				    <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit entry.</font>
					    <%}
				}%>
				    
				<a href="javascript:RefreshPage();"><img src="../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			<%}else{%>
				Not authorized to save terminal information.
			<%}%>
			</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="3" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF TERMINALS ::: </strong></div></td>
		</tr>
		<tr>
			<td width="40%" height="25" align="center" class="thinborder"><strong>IP Address  </strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Location</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 4){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
				<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				Not authorized.
			<%}%>
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