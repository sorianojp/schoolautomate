<%@ page language="java" import="utility.*,Accounting.Budget,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Setup Staff Positions</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this position?'))
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
	
	function CancelOperation(){
		location = "./budget_staff_positions.jsp";
	}
	
	function FocusField(){
		document.form_.level_name.focus();
	}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
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
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BUDGET","budget_staff_positions.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"");	
	Vector vRetResult = null;
	Vector vEditInfo = null;
		
	Budget budget = new Budget();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(budget.operateOnAuthLevel(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = budget.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Staff position successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Staff position successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Staff position successfully edited.";
			
			strPrepareToEdit = "";
		}
	}
	
	vRetResult = budget.operateOnAuthLevel(dbOP,request,4);
	
	if(strPrepareToEdit.length() > 0){
		vEditInfo = budget.operateOnAuthLevel(dbOP,request,3);
		if(vEditInfo == null)
			strErrMsg = budget.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./budget_staff_positions.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: BUDGET LEVEL SETUP ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Level Name:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("level_name");
				%>
				<input type="text" name="level_name" value="<%=strTemp%>" class="textbox" size="48" maxlength="256"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Order No. </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("order_no");
				%>
				<input type="text" name="order_no" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','order_no');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyInteger('form_','order_no')" size="5" maxlength="3" /></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("is_restricted"), "0");
						
					if(strTemp.equals("1"))
						strTemp = " checked";
					else
						strTemp = "";
				%>
				<input name="is_restricted" type="checkbox" value="1"<%=strTemp%>>
				<font size="1">Check if access is restricted.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(iAccessLevel > 1){
				if(vEditInfo != null && vEditInfo.size() > 0){%>
					<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<font size="1">click to edit budget level </font>&nbsp; 
				    <%}else{%>
					<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">click to save budget level. </font>&nbsp;			
				    <%}%>
				
				<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
				<font size="1">click to cancel/clear fields </font>
			    <%}else{%>
				Not authorized to add/edit budget level information.
			    <%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: BUDGET LEVEL LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Level Name </strong></td>
			<td width="9%" align="center" class="thinborder"><strong>Order No </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Access</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Level Status</strong></td>
			<td width="16%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
		<%
			int iCount = 1;
			for(int i = 0; i < vRetResult.size(); i += 5, iCount++){
		%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
				if(strTemp.equals("0"))
					strTemp = "Unrestricted";
				else
					strTemp = "Restricted";
			%>
			<td class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+4);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
				else
					strTemp = "Final";
			%>			
			<td class="thinborder"><%=strTemp%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
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
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
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