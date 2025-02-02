<%@ page language="java" import="utility.*, java.util.Vector, hr.GovtEvaluation" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Create Review Period</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function PageAction(strAction, strInfoIndex) {
		document.form_.page_action.value = strAction;
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function CancelRecord(){
		location ="./manage_rater_weights.jsp";
	}
	
	function FocusField(){
		document.form_.supervisor.focus();
	}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null; 
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERFORMANCE EVALUATION MANAGEMENT"),"0"));
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
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Performance Evaluation Management-Create Review Period","manage_rater_weights.jsp");
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
	GovtEvaluation eval = new GovtEvaluation();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(eval.operateOnRaterWeights(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = eval.getErrMsg();
		else 
			strErrMsg = "Rater weights updated successfully";
	}
	
	vRetResult = eval.operateOnRaterWeights(dbOP, request, 4);
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();">
<form action="manage_rater_weights.jsp" method="post" name="form_">

	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: RATER WEIGHTS MANAGEMENT PAGE ::::</strong></font>			</td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25"  width="3%">&nbsp;</td>
			<td width="17%">Supervisor : </td>
			<td width="30%">
				<%
					if(vRetResult != null && vRetResult.size() > 0){
						strTemp = (String)vRetResult.elementAt(0);
						strTemp = CommonUtil.formatFloat(strTemp, false);
					}
					else
						strTemp = WI.fillTextValue("supervisor");
				%>
				<input type="text" name="supervisor" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','supervisor');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','supervisor')" size="10" maxlength="10" /></td>
		    <td width="17%">Peer:</td>
		    <td width="33%">
				<%
					if(vRetResult != null && vRetResult.size() > 0){
						strTemp = (String)vRetResult.elementAt(3);
						strTemp = CommonUtil.formatFloat(strTemp, false);
					}
					else
						strTemp = WI.fillTextValue("peer");
				%>
				<input type="text" name="peer" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','peer');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','peer')" size="10" maxlength="10" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Self: </td>
			<td>
				<%
					if(vRetResult != null && vRetResult.size() > 0){
						strTemp = (String)vRetResult.elementAt(1);
						strTemp = CommonUtil.formatFloat(strTemp, false);
					}
					else
						strTemp = WI.fillTextValue("self");			
				%>
           		<input type="text" name="self" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','self');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','self')" size="10" maxlength="10" /></td>
		    <td>Client:</td>
		    <td>
				<%
					if(vRetResult != null && vRetResult.size() > 0){
						strTemp = (String)vRetResult.elementAt(4);
						strTemp = CommonUtil.formatFloat(strTemp, false);
					}
					else
						strTemp = WI.fillTextValue("client");
				%>
				<input type="text" name="client" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','client');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','client')" size="10" maxlength="10" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Subordinate: </td>
		  	<td colspan="3">
				<%
					if(vRetResult != null && vRetResult.size() > 0){
						strTemp = (String)vRetResult.elementAt(2);
						strTemp = CommonUtil.formatFloat(strTemp, false);
					}
					else
						strTemp = WI.fillTextValue("subordinate");			
				%>
           		<input type="text" name="subordinate" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','subordinate');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','subordinate')" size="10" maxlength="10" /></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
			
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="25%" height="25">&nbsp;</td>
			<td width="75%">
			<%if (iAccessLevel > 1){%>    
				<a href="javascript:PageAction('2','<%=(String)vRetResult.elementAt(0)%>');">
					<img src="../../../images/edit.gif" border="0"></a> 
				<font size="1">click to save changes</font>				
				&nbsp;
				<a href="javascript:CancelRecord();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">click to cancel and clear entries</font> 
			<%}%><td>
		</tr> 
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
			
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="1" height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#0D3371">
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>