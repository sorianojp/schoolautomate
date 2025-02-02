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
	
	function PrepareToEdit(index){
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = index;
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this work/activity?'))
				return;
		}
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function CancelRecord(){
		location ="./activities_mgmt.jsp";
	}
	
	function FocusField(){
		document.form_.activity_name.focus();
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
			"Admin/staff-HR Management-Performance Evaluation Management-Create Review Period","activities_mgmt.jsp");
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
	Vector vEditInfo = null;
	
	String strPrepareToEdit =  WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	GovtEvaluation eval = new GovtEvaluation();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(eval.operateOnGovtActivities(dbOP, request, Integer.parseInt(strTemp)) == null){
			strErrMsg = eval.getErrMsg();

		} else {
			if(strTemp.equals("0"))
				strErrMsg = "Work/activitity removed successfully";
			if(strTemp.equals("1"))
				strErrMsg = "Work/activitity recorded successfully";
			if(strTemp.equals("2"))
				strErrMsg = "Work/activitity updated successfully";
				
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = eval.operateOnGovtActivities(dbOP, request, 4);
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = eval.operateOnGovtActivities(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = eval.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();">
<form action="activities_mgmt.jsp" method="post" name="form_">

	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: WORK/ACTIVITY MANAGEMENT PAGE ::::</strong></font></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="22%">Work/Activity Name : </td>
			<td width="75%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("activity_name");
				%>
				<input name="activity_name" type="text" size="64" maxlength="128" value="<%=strTemp%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Weight: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(2);
						strTemp = CommonUtil.formatFloat(strTemp, false);
					}
					else
						strTemp = WI.fillTextValue("weight");			
				%>
           		<input type="text" name="weight" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					onBlur="AllowOnlyFloat('form_','weight');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','weight')" size="10" maxlength="10" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Unit of Measure : </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("unit");
				%>
           		<input name="unit" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
			
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="25%" height="25">&nbsp;</td>
			<td width="75%">
			<%if (iAccessLevel > 1){
				if (vEditInfo  == null){%>        
					<a href="javascript:PageAction('1','');">
						<img src="../../../images/save.gif" border="0" name="hide_save"></a> 
					<font size="1">click to save entry </font> 
				<%}else{ %>        
					<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a> 
					<font size="1">click to save changes</font>
				<%}// end else vEdit Info == null%> 
				
				<a href="javascript:CancelRecord();">
					<img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">click to cancel and clear entries</font> 
			<%}%><td>
		</tr> 
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr bgcolor="#B9B292">
			<td height="28" colspan="5" align="center" class="thinborder">
				<strong>::: LIST OF WORK/ACTIVITIES CREATED ::: </strong></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Name</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Weight</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Unit of Measure </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), false)%>%</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				No edit/delete privileges.
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}//if vRetResult is not null%>
			
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
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>