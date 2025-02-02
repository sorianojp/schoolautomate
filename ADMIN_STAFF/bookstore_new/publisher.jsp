<%@ page language="java" import="utility.*, citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Publisher</title>
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
	function PageAction(strAction, strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this Publisher?'))
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
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.submit();
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
	
	function ReloadPage(){
		document.form_.publisher_name.value = "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","publisher.jsp");
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
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-BOOK MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	String strIsTeamLead = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	
	BookManagement bm = new BookManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(bm.operateOnPublisher(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = bm.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Publisher successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Publisher successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Publisher successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = bm.operateOnPublisher(dbOP, request, 4);
	if(vRetResult == null){
		if(strTemp.length() == 0)
			strErrMsg = bm.getErrMsg();
	}

	if(strPrepareToEdit.equals("1")){
		vEditInfo = bm.operateOnPublisher(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = bm.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="form_" action="./publisher.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: PUBLISHER MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Publisher</td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("publisher_name");
				%>
				<input type="text" name="publisher_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="256" value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td valign="middle">
				<%if(iAccessLevel > 1){
					if(strPrepareToEdit.equals("0")) {%>
						<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
						<font size="1">Click to save publisher.</font>
						<%}else {
						if(vEditInfo!=null){%>
							<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
							<img src="../../images/edit.gif" border="0"></a>
							<font size="1">Click to edit publisher.</font>
						<%}
					}%>
					<a href="javascript:ReloadPage();"><img src="../../images/refresh.gif" border="0"></a>
					<font size="1">Click to refresh page.</font>
				<%}else{%>
					Not authorized to save publisher information.
			        <%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  PUBLISHER LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="10%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="65%" align="center" class="thinborder"><strong>Publisher Name </strong><strong></strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
		<%
			int iCount = 1;
			for(int i = 0; i < vRetResult.size(); i += 2, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
		  	<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../images/edit.gif" border="0" /></a>
				<%if(iAccessLevel == 2){%>
					&nbsp;&nbsp;
					<a href="javascript:PageAction(0,'<%=(String)vRetResult.elementAt(i)%>');"><img src="../../images/delete.gif" border="0" /></a>
				<%}
			}else{%>
				No edit/delete privilege.
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
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> 
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>